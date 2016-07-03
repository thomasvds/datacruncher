class Score < ActiveRecord::Base
  belongs_to :agent
  has_one :task

  def self.moving_average(values)
    if values.count < 4
      return values
    else
      average = []
      average[0] = values[0]
      average[1] = 0.5 * (values[0] + values[1])
      average[2] = 0.33333 * (values[0] + values[1] + values[2])
      (3...values.count).each do |i|
        average[i] = 0.25 * (values[i-3] + values[i-2] + values[i-1] + values[i])
      end
      return average
    end
  end

  def self.last_average(score)
    values = score.pluck(:value)
    i = values.count - 1
    return 0.25 * (values[i-3] + values[i-2] + values[i-1] + values[i])
  end

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
