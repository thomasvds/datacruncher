class CreateAgents < ActiveRecord::Migration
  def change
    create_table :agents do |t|
      t.string :name
      t.string :mail
      t.string :slack_id
      t.string :github_id
      t.string :trello_id
      t.string :gmail_id

      t.timestamps null: false
    end
  end
end
