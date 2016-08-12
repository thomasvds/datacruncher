# require 'jobs/PoliciesCheckJob'
# require 'jobs/ScoreComputationJob'
# require 'jobs/TasksCreationJob'

namespace :computations do
  desc "Clear checks and scores and recompute them"
  task :checks do
    PoliciesCheckJob.perform_now(Event.all)
    ScoreComputationJob.perform_now(Event.all)
    TasksCreationJob.perform_now
  end
end
