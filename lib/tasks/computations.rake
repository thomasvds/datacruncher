namespace :computations do
  desc "Clear checks and scores and recompute them"
  task :checks do
    Task.destroy_all
    PolicyCheck.destroy_all
    PoliciesCheckJob.perform_now(Event.all)
    Score.destroy_all
    ScoreComputationJob.perform_now(Event.all)
    Task.destroy_all
    TasksCreationJob.perform_now
  end
end
