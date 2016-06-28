require 'net/http'
require 'uri'
require 'json'
require 'csv'
require 'date'

# Extracts messages from a Slack team identified via its authentification
# token, from the channel identified via its unique channel ID.
# Default Slack channels.history API settings are used.

class SlackJob < ActiveJob::Base
  queue_as :default

  def perform(token, channel)
    json = retrieve_json(token, channel)
    create_events(json, channel)
  end

  private

  def retrieve_json(token, channel)
    token = "token=#{token}"
    channel = "channel=#{channel}"
    pretty = "pretty=1"
    url = "https://slack.com/api/channels.history?#{token}&#{pretty}&#{channel}"
    uri = URI.parse(url)
    response = Net::HTTP.get(uri)
    json = JSON.parse(response)
  end

  def create_events(json, channel)
    extracted = Time.now
    time =
    json["messages"].each do |msg|
      time = Time.at(msg["ts"].match(/\d+/)[0].to_i)
      Event.create(
        source: 'slack',
        source_channel: channel,
        source_agent_id: msg['user'],
        extraction_time: extracted,
        agent: Agent.where(slack_id: msg['user']).first,
        category: 'communication',
        time: time,
        date: time.to_date,
        hour: time.hour,
        minute: time.min
        )
    end
  end

  def write_csv
    extracted = Time.now
    csv_options = {col_sep: ';', write_headers: true, headers: ['source', 'extracted', 'user', 'date', 'hour']}
    CSV.open("test.csv", "w", csv_options) do |csv| #open new file for write
      @json["messages"].each do |msg| #open json to parse
        user = msg["user"]
        time = msg["ts"]
        time = time.match(/\d+/)[0].to_i
        time = Time.at(time)
        csv << [ 'slack', extracted, user, time.to_date, time.hour ] #write value to file
      end
    end
  end
end
