class Task < ActiveRecord::Base
  belongs_to :agent
  belongs_to :score
end
