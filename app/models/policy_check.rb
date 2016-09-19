class PolicyCheck < ActiveRecord::Base
  belongs_to :policy
  belongs_to :agent

  # Ensure no double-computations of Policies per agent
  validates_uniqueness_of :policy_id, scope: [:agent_id, :week, :year]
end
