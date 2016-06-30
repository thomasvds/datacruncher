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
    case self.adverb
    when "BEFORE"
      !Event.any_event_before?(events, self.firstparam)
    when "DURING"
      !Event.any_event_during?(events, self.firstparam, self.secondparam)
    when "AFTER"
      !Event.any_event_after?(events, self.firstparam)
    when "ON"
      !Event.any_event_on?(events, self.firstparam)
    end
  end
end
