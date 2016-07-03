class PolicyCheck < ActiveRecord::Base
  belongs_to :policy
  belongs_to :agent
end
