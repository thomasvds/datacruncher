class CreateStaffings < ActiveRecord::Migration
  def change
    create_table :staffings do |t|
      t.references :agent, index: true, foreign_key: true
      t.references :team, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
