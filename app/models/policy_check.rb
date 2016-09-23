class PolicyCheck < ActiveRecord::Base
  # == Constants ============================================================

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  # == Relationships ========================================================
  belongs_to :policy
  belongs_to :agent

  # == Validations ==========================================================
  validates :policy, presence: true
  validates :agent, presence: true
  validates :week, presence: true
  validates :year, presence: true
  # Ensure no double-computations of Policies per agent
  validates_uniqueness_of :policy_id, scope: [:agent_id, :week, :year]

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================
end
