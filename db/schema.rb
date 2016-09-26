# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160923090906) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agents", force: :cascade do |t|
    t.string   "name"
    t.string   "position"
    t.string   "mail"
    t.string   "slack_id"
    t.string   "github_id"
    t.string   "trello_id"
    t.string   "gmail_id"
    t.string   "picture_url"
    t.boolean  "super_care",  default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "events", force: :cascade do |t|
    t.string   "source"
    t.string   "source_channel"
    t.string   "source_agent_id"
    t.string   "extraction_time"
    t.integer  "agent_id"
    t.string   "category"
    t.datetime "time"
    t.date     "date"
    t.integer  "year"
    t.integer  "week"
    t.integer  "day"
    t.integer  "hour"
    t.integer  "minute"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "events", ["agent_id"], name: "index_events_on_agent_id", using: :btree

  create_table "policies", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "category",    default: "work"
    t.string   "timeframe"
    t.string   "adverb"
    t.integer  "hour"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "policy_checks", force: :cascade do |t|
    t.integer  "policy_id"
    t.integer  "agent_id"
    t.boolean  "enforced"
    t.integer  "week"
    t.integer  "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "policy_checks", ["agent_id"], name: "index_policy_checks_on_agent_id", using: :btree
  add_index "policy_checks", ["policy_id"], name: "index_policy_checks_on_policy_id", using: :btree

  create_table "policy_settings", force: :cascade do |t|
    t.float    "weight"
    t.boolean  "enabled",    default: false
    t.integer  "policy_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "policy_settings", ["policy_id"], name: "index_policy_settings_on_policy_id", using: :btree

  create_table "scores", force: :cascade do |t|
    t.integer  "agent_id"
    t.float    "weekly_value"
    t.float    "moving_average_value"
    t.integer  "week"
    t.integer  "year"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "scores", ["agent_id"], name: "index_scores_on_agent_id", using: :btree

  create_table "staffings", force: :cascade do |t|
    t.integer  "agent_id"
    t.integer  "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "staffings", ["agent_id"], name: "index_staffings_on_agent_id", using: :btree
  add_index "staffings", ["team_id"], name: "index_staffings_on_team_id", using: :btree

  create_table "tasks", force: :cascade do |t|
    t.string   "description"
    t.string   "comments"
    t.string   "owner"
    t.string   "category"
    t.datetime "due_date"
    t.datetime "done_date"
    t.boolean  "done",        default: false
    t.integer  "agent_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "tasks", ["agent_id"], name: "index_tasks_on_agent_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "events", "agents"
  add_foreign_key "policy_checks", "agents"
  add_foreign_key "policy_checks", "policies"
  add_foreign_key "policy_settings", "policies"
  add_foreign_key "scores", "agents"
  add_foreign_key "staffings", "agents"
  add_foreign_key "staffings", "teams"
  add_foreign_key "tasks", "agents"
end
