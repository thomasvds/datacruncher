class Agent < ActiveRecord::Base
  has_many :events
  has_many :scores
  has_many :policy_checks
  has_many :tasks
  has_many :staffings
  has_many :teams, through: :staffings

  def info_hash
    return {
      name: name,
      id: id,
      position: position,
      picture_url: picture_url
    }
  end
end
