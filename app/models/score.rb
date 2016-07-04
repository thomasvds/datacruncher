class Score < ActiveRecord::Base
  belongs_to :agent
  has_one :task

  def self.range(value)
    case value.round
    when 0..40
      "danger"
    when 41..60
      "warning"
    when 61..80
      "primary"
    when 81..100
      "success"
    end
  end
end
