class PolicyController < ApplicationController
  def index
    @policies = Policy.all
  end
end
