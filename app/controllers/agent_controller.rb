class AgentController < ApplicationController
  before_action :set_agent

  def show
    start_date  = Date.parse('2016-06-18')
    end_date    = Date.parse('2016-07-01')
    @xaxis, @hour_of_last_action = Event.hour_of_last_action_by_date(@agent, start_date, end_date)
  end

  def set_agent
    @agent = Agent.find(params[:id])
  end

  def agent_params
    params.require(:agent).permit(:id)
  end
end
