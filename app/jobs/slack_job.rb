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
    @token = token
    @channel = channel
    @filename = "#{Time.now.getutc.to_i.to_s}_slack.csv"
    json = retrieve_json
    write_csv(json)
    return @filename
  end

  private

  def retrieve_json
    token = "token=#{@token}"
    channel = "channel=#{@channel}"
    pretty = "pretty=1"
    url = "https://slack.com/api/channels.history?#{token}&#{pretty}&#{channel}"
    uri = URI.parse(url)
    response = Net::HTTP.get(uri)
    json = JSON.parse(response)
  end

  def write_csv(json)
    extracted = Time.now
    csv_options = {col_sep: ',', write_headers: false,
      headers: ['source',
        'source_channel',
        'source_agent_id',
        'extraction_time',
        'agent_id',
        'category',
        'time',
        'date',
        'hour',
        'minute']}
    CSV.open(@filename, "w", csv_options) do |csv| #open new file for write
      json["messages"].each do |msg| #open json to parse
        #Extract event characteristics
        time = Time.at(msg["ts"].match(/\d+/)[0].to_i)
        source = 'slack',
        source_channel = @channel,
        source_agent_id = msg['user'],
        extraction_time = extracted,
        agent_id = Agent.where(slack_id: msg['user']).first.id,
        category = 'communication',
        time = time,
        date = time.to_date,
        hour = time.hour,
        minute = time.min
        #Append event as new row to CSV file
        csv << [source,
        source_channel,
        source_agent_id,
        extraction_time,
        agent_id, category,
        time, date, hour, minute]
      end
    end
  end
end
