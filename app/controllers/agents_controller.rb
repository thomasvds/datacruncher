require 'active_support/core_ext/numeric/time'

class AgentsController < ApplicationController
  before_action :set_agent

  private

  def set_agent
    @agent = Agent.find(params[:id])
  end

  def agent_params
    params.require(:agent).permit(:id)
  end

end
