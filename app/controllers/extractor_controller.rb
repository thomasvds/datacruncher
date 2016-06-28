class ExtractorController < ApplicationController
  def slack
    before_count = Event.all.count
    before_time = Time.now
    SlackJob.perform_now(ENV['SLACK_TEST_TOKEN'], 'C0ARU9CHZ')
    @time = Time.now - before_time
    @count = Event.all.count - before_count
  end
end
