class OrchestractorController < ApplicationController
  def slack
    before_count = Event.all.count
    before_time = Time.now
    csv_filename = SlackJob.perform_now(ENV['SLACK_TEST_TOKEN'], 'C0ARU9CHZ')
    csv_to_db(csv_filename)
    @time = Time.now - before_time
    @count = Event.all.count - before_count
  end

  def csv_to_db(csv_filename)
    Event.transaction do
      events = CSV.read(csv_filename)
      columns = [:source,
        :source_channel,
        :source_agent_id,
        :extraction_time,
        :agent_id,
        :category,
        :time,
        :date,
        :hour,
        :minute]
        Event.import columns, events, validate: false
    end
  end
end
