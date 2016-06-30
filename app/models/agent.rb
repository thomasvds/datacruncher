class Agent < ActiveRecord::Base
  has_many :events
  has_many :scores
end
