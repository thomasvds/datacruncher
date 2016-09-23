class Score < ActiveRecord::Base
  # == Constants ============================================================
  WEEKS = (1..52)
  YEARS = (2000..DateTime.now.year)
  PERCENTAGES = (0..100)

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  # == Relationships ========================================================

  # == Validations ==========================================================
  validates :agent, presence: true
  validates :week, presence: true,
                   numericality: { only_integer: true },
                   inclusion: { in: WEEKS }
  validates :year, presence: true,
                   numericality: { only_integer: true },
                   inclusion: { in: YEARS }
  validates :weekly_value, presence: true,
                           numericality: true,
                           inclusion: { in: PERCENTAGES }
  validates :moving_average_value, presence: true,
                                   numericality: true,
                                   inclusion: { in: PERCENTAGES }
  # Ensure each agent has only one score per week per year, to avoid multiple
  # score computations that would lead to artificial score doubling
  validates_uniqueness_of :agent_id, scope: [:week, :year]

  # == Scopes ===============================================================
  belongs_to :agent
  has_one :task

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================
end
