# This job should be run just after PoliciesCheckJob has been run.
# Based on the policies settings for each policy, it goes through the
# policy compliance results for each week, and computes the sustainability
# score for each agent for this week.
class ScoreComputationJob < ActiveJob::Base
  def perform
    start_week =
    end_week =
    (start_week..end_week).each do |w|
      week_policy_checks = PolicyCheck.where(week: w)
      Agent.each do |a|
        agent_week_policy_checks = week_policy_checks.where(agent: a)
        value = 0
        Policy.each do |p|
          settings = PolicySettings.where(policy: p)
          if settings.enabled
            enforced = agent_week_policy_checks.where(policy: p).enforced
            if p.enforced
            value += settings.weight
          end
        end
        Score.create(agent: a, week: w, value: value)
      end
    end
  end
end
