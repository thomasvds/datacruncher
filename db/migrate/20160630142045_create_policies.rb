class CreatePolicies < ActiveRecord::Migration
  def change
    create_table :policies do |t|
      t.string :name
      t.string :description
      t.float :weight
      t.boolean :enabled
      t.string :category
      t.string :verb
      t.string :adverb
      t.integer :firstparam
      t.integer :secondparam

      t.timestamps null: false
    end
  end
end
