class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :description
      t.string :comments
      t.string :owner
      t.string :category
      t.datetime :due_date
      t.datetime :done_date
      t.boolean :done, default: false
      t.references :agent, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
