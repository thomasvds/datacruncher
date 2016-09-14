namespace :computations do
  desc "Clear checks and scores and recompute them"
  task :checks do
    PoliciesCheckJob.perform_now(Event.where(year: 2012))
    ScoreComputationJob.perform_now(Event.where(year: 2012))
    TasksCreationJob.perform_now
  end
end
