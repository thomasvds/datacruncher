class Team < ActiveRecord::Base
  has_many :staffings
  has_many :agents, through: :staffings

  def info_hash
    return {
      "name" => name,
      "id" => id
    }
  end
end
