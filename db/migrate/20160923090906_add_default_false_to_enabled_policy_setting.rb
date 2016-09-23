class AddDefaultFalseToEnabledPolicySetting < ActiveRecord::Migration
  def change
    change_column :policy_settings, :enabled, :boolean, default: false
  end
end
