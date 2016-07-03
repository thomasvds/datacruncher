class Policy < ActiveRecord::Base
  has_one :policy_setting
  has_many :policy_checks

  def self.all_time_scores(agent)
    start_date  = Date.parse('2016-04-01')
    end_date    = Date.parse('2016-06-26')

    agent_events = Event.where(agent: agent)

    start_week = start_date.cweek
    end_week = end_date.cweek

    week_xaxis = start_week..end_week
    scores = []

    week = start_week

    while week <= end_week
      wkstart = Date.commercial(2016, week, 1)
      wkend = Date.commercial(2016, week, 7)
      date_range = wkstart..wkend
      events = agent_events.where(date: date_range)
      policies_check_list, score = check_list(agent_events.where(date: date_range))
      scores << score
      week += 1
    end

    averages = []
    averages[0] = scores[0]
    averages[1] = 0.5 * (scores[0] + scores[1])
    averages[2] = 0.33333 * (scores[0] + scores[1] + scores[2])
    (3...scores.count).each do |i|
      averages[i] = 0.25 * (scores[i-3] + scores[i-2] + scores[i-1] + scores[i])
    end

    current_average_score = averages[-1].round

    return week_xaxis, {"weekly" => scores, "4-wks avg." => averages}, current_average_score, score_range(current_average_score)
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

  def self.score_range(score)
    case score
    when 0..40
      "danger"
    when 41..60
      "warning"
    when 61..80
      "primary"
    else
      "success"
    end
  end
end
