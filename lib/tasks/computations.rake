namespace :computations do
  desc "Clear checks and scores and recompute them"
  task :checks do
    PolicyCheck.destroy_all
    PoliciesCheckJob.perform_now(Event.all)
    Score.destroy_all
    ScoreComputationJob.perform_now(Event.all)
  end
end
