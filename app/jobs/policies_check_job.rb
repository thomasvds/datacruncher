# This job should be run once everytime a new series of events is made available
# from the various events sources. It goes through all the events, and for each
# agent it checks whether the events of this agent are compliant with existing
# policies. The compliance is computed on a weekly basis, and is by default
# computed for all the policies available, even the ones that have not been enabled.
class PoliciesCheckJob < ActiveJob::Base
  def perform(events)
    ordered_events = events.order(:year).order(:week)
    start_year = ordered_events.first.year
    end_year = ordered_events.last.year
    (start_year..end_year).each do |y|
      year_events = ordered_events.where(year: y)
      start_week = year_events.first.week
      end_week = year_events.last.week
      (start_week..end_week).each do |w|
        week_events = year_events.where(week: w)
        Agent.all.each do |a|
          agent_week_events = week_events.where(agent: a)
          Policy.all.each do |p|
            enforced = p.enforced?(agent_week_events)
            PolicyCheck.create(policy: p, agent: a, week: w, year: y, enforced: enforced)
          end
        end
      end
    end
  end
end
