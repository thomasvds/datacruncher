require 'net/http'
require 'uri'
require 'json'
require 'csv'
require 'date'

class SlackController < ApplicationController
  def extract
    @json = retrieve_json
    # write_csv
    create_events
  end

  private

  def retrieve_json
    token = "token=#{ENV['SLACK_TEST_TOKEN']}"
    pretty = "pretty=1"
    channel = "channel=C0ARU9CHZ"
    url = "https://slack.com/api/channels.history?#{token}&#{pretty}&#{channel}"
    uri = URI.parse(url)
    response = Net::HTTP.get(uri)
    json = JSON.parse(response)
  end

  def create_events
    extracted = Time.now
    @json["messages"].each do |msg|
      Event.create(
        source: 'slack',
        source_channel: 'C0ARU9CHZ',
        source_agent_id: msg['user'],
        extraction_time: extracted,
        agent: Agent.where(slack_id: msg['user']).first,
        category: 'communication',
        time: Time.at(msg["ts"].match(/\d+/)[0].to_i)
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
