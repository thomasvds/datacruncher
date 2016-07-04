class Staffing < ActiveRecord::Base
  belongs_to :agent
  belongs_to :team
end
