class Event < ActiveRecord::Base
  belongs_to :agent

  def self.volume_by_date(agents, start_date, end_date)
    date_range = start_date..end_date
    dates = date_range.map {|d| d.strftime '%d/%m' }

    data = Hash.new { |h, k| h[k] = []}
    agents.each do |agent|
      date_range.each do |date|
        data[agent.name] << Event.where(agent: agent, date: date).count
      end
    end

    return dates, data
  end

  def self.hour_of_last_action_by_date(agents, start_date, end_date)
    date_range = start_date..end_date
    dates = date_range.map {|d| d.strftime '%d/%m' }

    data = Hash.new { |h, k| h[k] = []}
    agents.each do |agent|
      date_range.each do |date|
        last_event = Event.where(agent: agent, date: date).order(:hour).last
        #TODO: have nice way to handle the time differences
        data[agent.name] <<  (last_event.nil? ? 0 : last_event.hour )
      end
    end

    return dates, data
  end

  def self.time_split(agent, start_date, end_date)
    events = Event.where(agent: agent, date: start_date..end_date)
    split = Hash.new { |h, k| h[k] = []}
    split["before_18"] = events.where("hour > ?", 18).count
    split["after_20"] = events.where("hour >= ?", 20).count
    split["between_18_and_20"] = events.count - split["before_18"] - split["after_20"]
    return split
  end
end
