class Team < ActiveRecord::Base
  has_many :staffings
  has_many :agents, through: :staffings
end
