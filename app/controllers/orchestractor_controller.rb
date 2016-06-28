class OrchestractorController < ApplicationController
  def slack
    csv_filename = SlackJob.perform_now(ENV['SLACK_TEST_TOKEN'], 'C0ARU9CHZ')
    csv_to_db(csv_filename)
  end

  def github
    csv_filename = GithubJob.perform_now
    csv_to_db(csv_filename)
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
