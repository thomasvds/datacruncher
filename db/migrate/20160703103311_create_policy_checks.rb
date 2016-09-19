class CreatePolicyChecks < ActiveRecord::Migration
  def change
    create_table :policy_checks do |t|
      t.references :policy, index: true, foreign_key: true
      t.references :agent, index: true, foreign_key: true
      t.boolean :enforced
      t.integer :week
      t.integer :year

      t.timestamps null: false
    end
  end
end
