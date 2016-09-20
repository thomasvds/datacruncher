class Score < ActiveRecord::Base
  belongs_to :agent
  has_one :task

  # Ensure each agent has only one score per week per year, to avoid multiple
  # score computations that would lead to artificial score doubling
  validates_uniqueness_of :agent_id, scope: [:week, :year]
end
