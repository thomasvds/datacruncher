class CreatePolicies < ActiveRecord::Migration
  def change
    create_table :policies do |t|
      t.string :name
      t.string :description
      t.string :category, default: "work"
      t.string :timeframe
      t.string :adverb
      t.integer :hour
      t.timestamps null: false
    end
  end
end
