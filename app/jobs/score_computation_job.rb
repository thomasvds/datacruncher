# This job should be run just after PoliciesCheckJob has been run.
# Based on the policies settings for each policy, it goes through the
# policy compliance results for each week, and computes the sustainability
# score for each agent for this week.
class ScoreComputationJob < ActiveJob::Base
  def perform(events)
    ordered_events = events.order(:week)
    start_week = ordered_events.first.week
    end_week = ordered_events.last.week
    (start_week..end_week).each do |w|
      week_policy_checks = PolicyCheck.where(week: w)
      Agent.all.each do |a|
        agent_week_policy_checks = week_policy_checks.where(agent: a)
        value = 0
        Policy.all.each do |p|
          settings = PolicySetting.where(policy: p).first
          if settings.enabled
            enforced = agent_week_policy_checks.where(policy: p).first.enforced
            if enforced
              value += settings.weight
            end
          end
        end
        Score.create(agent: a, week: w, value: value * 100)
      end
    end
  end
end
