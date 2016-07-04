# This job should be run just after PoliciesCheckJob has been run.
# Based on the policies settings for each policy, it goes through the
# policy compliance results for each week, and computes the sustainability
# score for each agent for this week.
class ScoreComputationJob < ActiveJob::Base
  def perform(events)
    # First compute the weekly value for each score
    ordered_events = events.order(:week)
    start_week = ordered_events.first.week
    end_week = ordered_events.last.week
    (start_week..end_week).each do |w|
      # Retrieve the check lists for the policies
      week_policy_checks = PolicyCheck.where(week: w)
      Agent.all.each do |a|
        agent_week_policy_checks = week_policy_checks.where(agent: a)
        weekly_value = 0
        # Check for each policy whether it is enabled and is enforced
        Policy.all.each do |p|
          settings = PolicySetting.where(policy: p).first
          # Only consider the policy for score computation if it is enabled
          if settings.enabled
            enforced = agent_week_policy_checks.where(policy: p).first.enforced
            if enforced
              # If the policy has been enforced, use its weight to add up to the score
              weekly_value += settings.weight
            end
          end
        end
        # Create the score element, indexing it on a 100% basis
        Score.create(agent: a, week: w, weekly_value: weekly_value * 100)
      end
    end
    # Then compute the 4-weeks moving average linked to each weekly score
    Agent.all.each do |a|
      scores = Score.where(agent: a).order(:week)
      # Handle irregular starting conditions
      # Retrieve the 3 first scores
      one = scores.first.weekly_value
      two = scores.second.weekly_value
      three = scores.third.weekly_value
      # Compute the 3 first moving averages
      first_avg = one
      # Pay extra attention to the fact that in Ruby 1/2 and 1/3 yield zero!
      # Directly use decimals instead, lazy way vs. using div methods.
      second_avg = 0.5 * (one + two)
      third_avg = 0.333333 * (one + two + three)
      # Update the 3 first scores with their moving averages
      scores.first.update(moving_average_value: first_avg)
      scores.second.update(moving_average_value: second_avg)
      scores.third.update(moving_average_value: third_avg)
      # Save the last 3 weekly values, and then start iterating as of the 4th one
      previous_weekly_values = [one, two, three]
      scores.offset(3).each do |s|
        # Compute the moving average at that point
        avg = 0.25 * (previous_weekly_values.sum + s.weekly_value)
        s.update(moving_average_value: avg)
        # Then update the array of 4 last weekly values
        # Remove the first element of the previous weekly values
        previous_weekly_values.shift
        # Then insert at the end the latest value
        previous_weekly_values.push(s.weekly_value)
      end
    end
  end
end
