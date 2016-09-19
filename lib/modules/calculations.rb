module Calculations
  # Range nomenclature
  RANGE = {
    'great' => 81..100,
    'good' => 61..80,
    'warning' => 41..60,
    'danger' => 0..40
  }

  # For all calculation covering exactly 1 individual
  module Individuals
    # Returns a hash with the score and its range during a given week, with the
    # option to return the moving average value for the given week
    def individual_week_score_and_range(agent, week, year, moving_average = 'weekly')
      if moving_average == 'moving_average'
        score = Score.where(agent: agent, week: week, year: year).first.moving_average_value.round
      else
        score = Score.where(agent: agent, week: week, year: year).first.weekly_value.round
      end
      range = value_range(score)
      return {'score' => score, 'range' => range}
    end

    # Returns a hash with the three most commonly used score values and ranges:
    # weekly score, previous week score, and current moving average score
    def individual_scores_snapshot(agent, week, year)
      return {
        "last week" => individual_week_score_and_range(agent, week, year),
        "week before last" => individual_week_score_and_range(agent, week-1, year),
        "all time" => individual_week_score_and_range(agent, week, year, 'moving_average')
      }
    end
  end

  # For all calculations covering more than 1 individual (e.g., related
  # to company-wide, peer groups, and teams metrics)
  module Groups

    # For all calculations related to aggregated sustainability scorings
    module Scores

      # Returns the average score of the given agents collection during
      # the given week of the given year
      # TODO handle the case of no score existing for a given week, currently
      # put at 100 by default
      def group_score(agents, week, year = 2016)
        members_scores = Score.where(agent: agents, week: week, year: year).pluck(:weekly_value)
        if members_scores.count >= 1
          return members_scores.sum.fdiv(members_scores.count).round
        else
          return 100
        end
      end

      # Returns the number of agents within a certain score range during
      # the given week of the given year
      def count_per_score_range(agents, range, week, year = 2016)
        values = Calculations::RANGE[range]
        return Score.where(week: week, weekly_value: values, year: year, agent: agents).count
      end

      # For a given range, returns a hash containing its value for the given week
      # and for the week before, along with a trend description
      def score_range_weekly_evolution_snapshot(agents, range, week, year = 2016)
        response = {}
        response['week_count'] = count_per_score_range(agents, range, week, year)
        response['previous_week_count'] = count_per_score_range(agents, range, week - 1, year)
        response['evolution'] = trend(response['previous_week_count'], response['week_count'])
        return response
      end

      # Returns a full description of all ranges evolutions for the given week,
      # in the form of an array of hashes where each hash contains the range name,
      # weekly and previous weekly value, and the weekly trend
      def all_score_ranges_weekly_evolution_overview(agents, week, year = 2016)
        response = []
        Calculations::RANGE.each do |range_name, range_values|
          element = {'range_name' => range_name}
          response << element.merge(score_range_weekly_evolution_snapshot(agents, range_name, week, year))
        end
        return response
      end
    end

    # For all calculations related to specific sustainability policies
    module Policies

      # Returns the percentage of enforcement of the given policy for the
      # given group during the given week of the given year
      # TODO: handle 1-agent query in a nicer way
      def group_policy_percentage(agents, policy, week, year = 2016)
        number_enforced = PolicyCheck.where(week: week, year: year, policy: policy, agent: agents, enforced: true).count
        if agents.respond_to?(:count)
          return (number_enforced.fdiv(agents.count) * 100).round
        else
          return number_enforced * 100
        end
      end

      # Returns an array of hashes that is a full description of all policies
      # enforcement for the given week, for enabled policies only. Each hash
      # contains the policy name, weekly value, weekly value range, and the
      # policy weight normalized to 100
      def all_policies_weekly_percentage_overview(agents, week, year = 2016)
        response = []
        Policy.enabled.each do |policy|
          value = group_policy_percentage(agents, policy, week, year)
          response << {
            'name' => policy.name,
            'weight' => (policy.policy_setting.weight * 100).round(1),
            'value' => value,
            'range' => value_range(value)
          }
        end
        return response
      end
    end
  end

  # Various utility functions
  module Utilities

    # Returns the range name for a given value
    def value_range(value)
      Calculations::RANGE.each do |range_name, range_values|
        if range_values.cover?(value)
          return range_name
        end
      end
    end

    # Returns an English description of a 2-values sequence trend
    def trend(value_before, value_after)
      delta = value_after - value_before
      case
      when delta == 0
        return 'right'
      when delta > 0
        return 'up'
      when delta < 0
        return 'down'
      end
    end
  end
end

