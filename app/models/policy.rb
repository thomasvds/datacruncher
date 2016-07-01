class Policy < ActiveRecord::Base

  def self.check_list(events)
    score = 0
    check_list_output = {}
    where(enabled: true).each do |policy|
      enforced = policy.enforced?(events)
      check_list_output[policy.name] = enforced
      enforced ? increment = 1 : increment = 0
      score += policy.weight * increment
    end
    score = (score * 100).round
    return check_list_output, score
  end

  def enforced?(events)
    # events = events.where(category: @category)
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
