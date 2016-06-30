class Event < ActiveRecord::Base
  belongs_to :agent
  CATEGORIES = ['production', 'communication', 'consultation', 'other']

  def self.volume_by_date(agent, start_date, end_date)
    date_range = start_date..end_date
    dates = date_range.map {|d| d.strftime '%d/%m' }

    data = Hash.new { |h, k| h[k] = []}

    CATEGORIES.each do |c|
      date_range.each do |date|
        data[c] << Event.where(agent: agent, date: date).count
      end
    end

    return dates, data
  end

  def self.hour_of_last_event_by_date(agent, date_range)
    result = Hash.new { |h, k| h[k] = []}

    CATEGORIES.each do |category|
      date_range.each do |date|
        last = last_event_of_day(agent, category, date)
        result[category] <<  ( last.nil? ? nil : last.hour )
      end
    end
    return result
  end

  def self.last_event_of_day(agent, category, date)
    Event.where(agent: agent, category: category, date: date).order(:hour).last
  end

  def self.time_split(agent, start_date, end_date)
    events = Event.where(agent: agent, date: start_date..end_date)
    split = Hash.new { |h, k| h[k] = []}
    split["before_18"] = events.where("hour > ?", 18).count
    split["after_20"] = events.where("hour >= ?", 20).count
    split["between_18_and_20"] = events.count - split["before_18"] - split["after_20"]
    return split
  end

  def self.any_event_before?(events, end_hour)
    events.each do |e|
      if e.hour < end_hour
        return true
      end
    end
    return false
  end

  def self.any_event_during?(events, start_hour, end_hour)
    events.each do |e|
      if e.hour >= start_hour && e.hour < end_hour
        return true
      end
    end
    return false
  end

  def self.any_event_after?(events, start_hour)
    events.each do |e|
      if e.hour >= start_hour
        return true
      end
    end
    return false
  end

  def self.any_event_on?(events, wday)
    events.each do |e|
      if e.date.wday == wday
        return true
      end
    end
    return false
  end
end
