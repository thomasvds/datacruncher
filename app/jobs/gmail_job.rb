require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'net/http'
require 'uri'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Flaresights'
CLIENT_SECRETS_PATH = 'client_secret.json'
CREDENTIALS_PATH = File.join('config','gmail-ruby-quickstart.yml')
SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_READONLY

class GmailJob < ActiveJob::Base
  queue_as :default

  def perform
    # Initialize the API
    service = Google::Apis::GmailV1::GmailService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize
    # Show the user's labels
    user_id = 'vanderstraeten.thomas'
    ACCESS_TOKEN = "ya29.Ci8PA9E_Kq8YUE2ZCjkggBbsQJ5pdQvdVcOqDD5hZjmNGHCoLT5jSh2kQbLzi1eAyQ"
    url = "https://www.googleapis.com/gmail/v1/users/#{user_id}/history?key=#{ACCESS_TOKEN}"
    uri = URI.parse(url)
    response = Net::HTTP.get(uri)
  end

  private

  def authorize
    client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(
      client_id, SCOPE, token_store)
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
  end


end




