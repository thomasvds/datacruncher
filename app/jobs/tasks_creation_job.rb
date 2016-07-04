class TasksCreationJob < ActiveJob::Base
  def perform
    current_week = Score.all.order(:week).last.week
    current_week_scores = Score.where(week: current_week-1)
    current_week_scores.each do |s|
      if s.weekly_value < 60
        Task.create(agent: s.agent, score: s, owner: "HR", description: "Check situation with the employee")
      end
    end
  end
end
