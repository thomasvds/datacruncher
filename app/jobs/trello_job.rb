require 'net/http'
require 'uri'
require 'json'

url = "https://trello.com/b/rq2mYJNn/public-trello-boards.json"
uri = URI(url)
response = Net::HTTP.get(uri)
json = JSON.parse(response)

filename = "#{Time.now.getutc.to_i.to_s}_trello.csv"
p filename
