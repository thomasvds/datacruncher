module Calculations
  # OVERALL GUIDELINES:
  #   - Methods that provide overviews of sets (of policies, of Individuals, of teams)
  #     should always return array of hashes. This way they can be easily iterated on
  #     in the view
  #   - Methods dealing with scores should use the hash key 'score' for the actual
  #     sustainability score
  #   - Methods dealing with policies should use the hash key 'value' for the actual
  #     policy enforcement metric percentage. This to avoid any confusion with the
  #     reserved keyword 'score' used only for sustainability (and computed based on
  #     individual policies values)
  #   - All roundings should happen within this Calculations module, and none should
  #     be done elsewhere (i.e., nor in Controllers nor in Views). They are configured
  #     in the constant METRICS_ROUNDING_LEVEL
  #   - The RANGES keys names should not be changed as they related to css styles.
  #     Indeed, these keys are specifically handled to the Controller and then to
  #     the Views, that will use them to style specific labels etc. Changing the
  #     names would thus break the styling in the Views
  #   - The current week should always be referred to as 'week', while the week
  #     before should be referred to as 'previous_week', and the moving average
  #     should be referred to as 'moving_average'
  #

  # Range nomenclature
  RANGE = {
    'great' => 81..100,
    'good' => 61..80,
    'warning' => 41..60,
    'danger' => 0..40
  }

  # Default score and range in case no score exists
  DEFAULT_SCORE = nil
  DEFAULT_SCORE_RANGE = 'none'

  # Rounding level: use no decimals
  METRICS_ROUNDING_LEVEL = 0

  # For all calculation covering exactly 1 individual
  module Individuals
    # Return hash with the score and its range during a given week
    def individual_week_score_and_range(agent, week, year)

      raise ArgumentError, 'Agent must be a single Agent, not a collection' unless agent.instance_of?(Agent)

      score = Score.where(agent: agent, week: week, year: year).first
      score.nil? ? score = Calculations::DEFAULT_SCORE : score = score.weekly_value.round(Calculations::METRICS_ROUNDING_LEVEL)
      range = value_range(score)
      return { score: score, range: range }
    end

    # Return the moving average value for the given week
    def individual_moving_average_score_and_range(agent, week, year)

      raise ArgumentError, 'Agent must be a single Agent, not a collection' unless agent.instance_of?(Agent)

      score = Score.where(agent: agent, week: week, year: year).first
      score.nil? ? score = Calculations::DEFAULT_SCORE : score = score.moving_average_value.round(Calculations::METRICS_ROUNDING_LEVEL)
      range = value_range(score)
      return { score: score, range: range }
    end

    # Returns hash with the three hashes of most commonly used score values and ranges:
    # weekly score, previous week score, and current moving average score
    def individual_scores_snapshot(agent, week, year)

      raise ArgumentError, 'Agent must be a single Agent, not a collection' unless agent.instance_of?(Agent)

      return {
        week: individual_week_score_and_range(agent, week, year),
        previous_week: individual_week_score_and_range(agent, week - 1, year),
        moving_average: individual_moving_average_score_and_range(agent, week, year)
      }
    end
  end

  # For all calculations covering more than 1 individual (e.g., related
  # to company-wide, peer groups, and teams metrics)
  module Groups

    # For all calculations related to aggregated sustainability scorings
    module Scores

      # Returns the average score of the given agents collection during
      # the given week of the given year, for the agents that have a score
      # for this week (other agents filtered out). If there is no score at all
      # that exists for this week, "nil" is returned instead; it appears as
      # a blank point in the highcharts charts in the view.
      def group_weekly_score(agents, week, year)

        raise ArgumentError, 'Agents must be a collection, not a single agent' unless agents.respond_to?(:count)
        raise ArgumentError, 'Agents must contain at least one agent' unless agents.count > 0

        members_scores = Score.where(agent: agents, week: week, year: year).pluck(:weekly_value)

        return nil unless members_scores.count > 0
        # Note: important to use a count of members_scores vs. on agents,
        # so that agents that don't have a score for the week are not counted
        # in in the average - they are basically left out
        return members_scores.sum.fdiv(members_scores.count).round(Calculations::METRICS_ROUNDING_LEVEL)
      end

      # Returns array of hashes where each hash contains the agent details
      # and its three common score metrics
      def group_array_of_info_and_scores(agents, week, year)

        raise ArgumentError, 'Agents must be a collection, not a single agent' unless agents.respond_to?(:count)
        raise ArgumentError, 'Agents must contain at least one agent' unless agents.count > 0

        response = []
        agents.each do |a|
          response << {
            agent: a.info_hash,
            scores: individual_scores_snapshot(a, week, year)
          }
        end
        return response
      end

      # Returns integer number of agents within a certain score range during
      # the given week of the given year
      def count_per_score_range(agents, range, week, year)

        raise ArgumentError, 'Agents must be a collection, not a single agent' unless agents.respond_to?(:count)
        raise ArgumentError, 'Agents must contain at least one agent' unless agents.count > 0
        raise ArgumentError, 'This range does not exist, check the spelling' unless Calculations::RANGE.include?(range)

        value = Calculations::RANGE[range]
        return Score.where(week: week, weekly_value: value, year: year, agent: agents).count
      end

      # Returns hash containing count per range for the given week
      # and for the week before, along with a trend description
      def score_range_weekly_evolution_snapshot(agents, range, week, year)

        raise ArgumentError, 'Agents must be a collection, not a single agent' unless agents.respond_to?(:count)
        raise ArgumentError, 'Agents must contain at least one agent' unless agents.count > 0
        raise ArgumentError, 'This range does not exist, check the spelling' unless Calculations::RANGE.include?(range)

        response = {}
        response[:week_count] = count_per_score_range(agents, range, week, year)
        response[:previous_week_count] = count_per_score_range(agents, range, week - 1, year)
        response[:evolution] = trend(response[:previous_week_count], response[:week_count])
        return response
      end

      # Returns array of hashes that is a full description of all ranges
      # evolutions for the given week, where each hash contains the range name,
      # weekly and previous weekly value, and the weekly trend
      def all_score_ranges_weekly_evolution_overview(agents, week, year)

        raise ArgumentError, 'Agents must be a collection, not a single agent' unless agents.respond_to?(:count)
        raise ArgumentError, 'Agents must contain at least one agent' unless agents.count > 0

        response = []
        Calculations::RANGE.each do |range_name, range_values|
          element = { range: range_name }
          response << element.merge(score_range_weekly_evolution_snapshot(agents, range_name, week, year))
        end
        return response
      end
    end

    # For all calculations related to specific sustainability policies
    module Policies

      # Returns the percentage of enforcement of the given policy for the
      # given group during the given week of the given year. Note that this
      # method is agnostic of the enabled/disabled state of the policy
      def group_policy_percentage(agents, policy, week, year)

        raise ArgumentError, 'Agents must be a collection, not a single agent' unless agents.respond_to?(:count)
        raise ArgumentError, 'Agents must contain at least one agent' unless agents.count > 0

        number_enforced = PolicyCheck.where(week: week, year: year, policy: policy, agent: agents, enforced: true).count
        return (number_enforced.fdiv(agents.count) * 100).round(Calculations::METRICS_ROUNDING_LEVEL)
      end

      # Returns an array of hashes that is a full description of all policies
      # enforcement for the given week, for enabled policies only. Each hash
      # contains the policy name, weekly value, weekly value range, and the
      # policy weight normalized to 100
      def all_policies_weekly_percentage_overview(agents, week, year)
        # Convert the agents argument to an array, as this enable to
        # reuse the method for individuals too
        agents = [agents] unless agents.respond_to?(:count)

        raise ArgumentError, 'Agents must contain at least one agent' unless agents.count > 0

        response = []
        Policy.enabled.each do |policy|
          value = group_policy_percentage(agents, policy, week, year)
          response << {
            name: policy.name,
            weight: (policy.policy_setting.weight * 100).round(1),
            value: value,
            range: value_range(value)
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

      return Calculations::DEFAULT_SCORE_RANGE if value == Calculations::DEFAULT_SCORE

      raise ArgumentError, 'Value should be comprised between 0 and 100, or be the default score if no score exists' unless (0..100).cover?(value)

      Calculations::RANGE.each do |range_name, range_values|
        if range_values.cover?(value)
          return range_name
        end
      end
    end

    # Returns an English description of a 2-values sequence trend. Note that
    # the name of these trends is used in the view to load the associated
    # font-awesome icons. Any change in the naming will thus break the view style.
    def trend(value_before, value_after)
      delta = value_after - value_before
      return "right" if delta == 0
      return "up" if delta > 0
      return "down" if delta < 0
    end
  end
end

