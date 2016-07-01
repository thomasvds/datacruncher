class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :source
      t.string :source_channel
      t.string :source_agent_id
      t.string :extraction_time
      t.references :agent, index: true, foreign_key: true
      t.string :category
      t.datetime :time
      t.date :date
      t.integer :day
      t.integer :hour
      t.integer :minute
      t.timestamps null: false
    end
  end
end
