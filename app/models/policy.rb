class Policy < ActiveRecord::Base
  has_one :policy_setting
  has_many :policy_checks

  # Returns only the enabled policies
  def self.enabled
    all.select { |policy| policy.enabled? == true }
  end

  # Shortcut to check whether policy is enabled
  def enabled?
    return policy_setting.enabled
  end

  # This method checks whether a series of events complies with the policy,
  # and should be used on a weekly basis only. That is, events provided in input
  # should only belong to one specific week.
  # This method is used by the PoliciesCheckJob to compute compliance for each
  # week for each agent.
  def enforced?(events)
    case self.timeframe
    when "at least once from Monday to Thursday"
      check = []
      (1..4).each do |d|
        check << !Event.any_event_after?(events.where(day: d), self.hour)
      end
      return check.include?(true)
    when "on Mondays"
      events = events.where(day: 1)
    when "on Tuesdays"
      events = events.where(day: 2)
    when "on Wednesdays"
      events = events.where(day: 3)
    when "on Thursdays"
      events = events.where(day: 4)
    when "on Fridays"
      events = events.where(day: 5)
    when "on Saturdays"
      events = events.where(day: 6)
    when "on Sundays"
      events = events.where(day: 0)
    when "on weekends"
      events = events.where(day: [0, 6])
    when "on weekdays"
      events = events.where(day: 1..5)
    end

    case self.adverb
    when "before"
      return !Event.any_event_before?(events, self.hour)
    when "after"
      return !Event.any_event_after?(events, self.hour)
    when "at all"
      return events.count == 0
    end
  end
end
