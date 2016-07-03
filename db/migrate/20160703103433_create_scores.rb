class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.references :agent, index: true, foreign_key: true
      t.integer :value
      t.integer :week

      t.timestamps null: false
    end
  end
end
