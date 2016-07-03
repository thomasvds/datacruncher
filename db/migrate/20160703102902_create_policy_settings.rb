class CreatePolicySettings < ActiveRecord::Migration
  def change
    create_table :policy_settings do |t|
      t.float :weight
      t.boolean :enabled
      t.references :policy, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
