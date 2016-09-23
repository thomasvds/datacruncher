class Agent < ActiveRecord::Base

  # == Constants ============================================================

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  # == Relationships ========================================================
  has_many :events
  has_many :scores
  has_many :policy_checks
  has_many :tasks
  has_many :staffings
  has_many :teams, through: :staffings

  # == Validations ==========================================================
  validates :name, presence: true
  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================
  def info_hash
    return {
      name: name,
      id: id,
      position: position,
      picture_url: picture_url
    }
  end
end
