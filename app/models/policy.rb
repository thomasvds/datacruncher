class Policy < ActiveRecord::Base
  has_many :scores

  def compliant?(events = Event.all)
    # events = events.where(category: @category)
    case self.verb
    when "IS NOT"
      check(events) ? false : true
    when "IS ONLY"
      check(events) ? 1 : 0
    end
  end

  private

  def check(events)
    case self.adverb
    when "BEFORE"
      exist_before(events, self.firstparam)
    when "DURING"
      exist_during(events, self.firstparam, self.secondparam)
    when "AFTER"
      exist_after(events, self.firstparam)
    when "ON"
      exist_on(events, self.firstparam)
    end
  end

  def exist_before(events, end_hour)
    events.each do |e|
      if e.hour < end_hour
        return true
      end
    end
    return false
  end

  def exist_during(events, start_hour, end_hour)
    events.each do |e|
      if e.hour >= start_hour && e.hour < end_hour
        return true
      end
    end
    return false
  end

  def exist_after(events, start_hour)
    events.each do |e|
      if e.hour >= start_hour
        return true
      end
    end
    return false
  end

  def exist_on(events, wday)
    events.each do |e|
      if e.date.wday == wday
        return true
      end
    end
    return false
  end
end
