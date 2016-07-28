require 'net/http'
require 'uri'
require 'json'
require 'date'
require 'csv'

url = "https://trello.com/b/nPNSBZjB/trello-resources.json"
uri = URI(url)
response = Net::HTTP.get(uri)
json = JSON.parse(response)

filename = "#{Time.now.getutc.to_i.to_s}_trello.csv"

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

CSV.open(filename, 'w', csv_options) do |csv|
  json['cards'].each do |card|
    source = "trello"
    source_channel = ""
    card_time = card['dateLastActivity'][0...-5]
    time = DateTime.strptime("#{card_time}", '%Y-%m-%dT%H:%M:%S')
    date = time.strftime('%Y%m%d')
    hour = time.strftime('%H')
    minute = time.strftime('%M')
    source_agent_id = card['id']
    extraction_time = Time.now
    agent_id = 'nil'
    category = "production"
    csv << [source,
    source_channel,
    source_agent_id,
    extraction_time,
    agent_id, category,
    time, date, hour, minute]
  end
end



json['cards'].size

# CSV.open(@filename, "w", csv_options) do |csv| #open new file for write
#   json.each do |event| #open json to parse
#     #Extract event characteristics
#     time = event['created_at']
#     #TODO: use a real datetime object instead of github created_at
#     time_match = time.scan(/[^A-Z:]*/)
#     source_agent_id = event['actor']['id']
#     extraction_time = extracted
#     agent_id = Agent.where(github_id: source_agent_id).first.id
#     category = 'production'
#     date = time_match[0]
#     hour = time_match[2]
#     minute = time_match[4]
#     #Append event as new row to CSV file
#     csv << ['github',
#     @channel,
#     source_agent_id,
#     extraction_time,
#     agent_id, category,
#     time, date, hour, minute]
