class TasksCreationJob < ActiveJob::Base
  def perform
    current_week = Score.all.order(:week).last.week
    current_week_scores = Score.where(week: current_week)
    current_week_scores.each do |s|
      if s.moving_average_value < 60
        s.agent.update(super_care: true)
        Task.create(done: true, due_date: Time.now, agent: s.agent, owner: "HR", category: "Flag", description: "Automatically moved to supercare")
      end
    end
  end
end
