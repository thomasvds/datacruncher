require 'net/http'
require 'uri'
require 'json'

class SlackController < ApplicationController
  def extract
    url = 'https://slack.com/api/api.test?pretty=1'
    uri = URI.parse(url)
    response = Net::HTTP.get(uri)
    return JSON.parse(response)
  end
end
