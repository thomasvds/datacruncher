require 'net/http'
require 'uri'
require 'json'
require 'csv'
require 'date'

#TODO COMMENT

class GithubJob < ActiveJob::Base
  queue_as :default

  def perform(token = "", channel = "")
    @token = token
    @channel = channel
    @filename = "#{Time.now.getutc.to_i.to_s}_github.csv"
    json = retrieve_json
    write_csv(json)
    return @filename
  end

  private

  def retrieve_json
    url = "https://api.github.com/repos/thomasvds/datacruncher/events"
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
      json.each do |event| #open json to parse
        #Extract event characteristics
        time = event['created_at']
        #TODO: use a real datetime object instead of github created_at
        time_match = time.scan(/[^A-Z:]*/)
        source_agent_id = event['actor']['id']
        extraction_time = extracted
        agent_id = Agent.where(github_id: source_agent_id).first.id
        category = 'production'
        date = time_match[0]
        hour = time_match[2]
        minute = time_match[4]
        #Append event as new row to CSV file
        csv << ['github',
        @channel,
        source_agent_id,
        extraction_time,
        agent_id, category,
        time, date, hour, minute]
      end
    end
  end
end
