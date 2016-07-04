class CreateAgents < ActiveRecord::Migration
  def change
    create_table :agents do |t|
      t.string :name
      t.string :position
      t.string :mail
      t.string :slack_id
      t.string :github_id
      t.string :trello_id
      t.string :gmail_id
      t.string :picture_url

      t.timestamps null: false
    end
  end
end
