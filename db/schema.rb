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

ActiveRecord::Schema.define(version: 20150614221958) do

  create_table "draft_statuses", force: :cascade do |t|
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leagues", force: :cascade do |t|
    t.string   "name",            null: false
    t.integer  "sport_id",        null: false
    t.string   "password",        null: false
    t.integer  "size",            null: false
    t.integer  "rounds",          null: false
    t.integer  "user_id",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "draft_status_id"
  end

  create_table "picks", force: :cascade do |t|
    t.integer  "overall_pick", null: false
    t.integer  "player_id"
    t.integer  "round",        null: false
    t.integer  "round_pick",   null: false
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "players", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name",  null: false
    t.string   "position",   null: false
    t.string   "team",       null: false
    t.text     "injury"
    t.text     "headline"
    t.text     "photo_url"
    t.string   "sport_id",   null: false
    t.string   "pro_status"
    t.string   "orig_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sports", force: :cascade do |t|
    t.string   "name",                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "positions",  default: "--- []\n"
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name",                  null: false
    t.string   "short_name", limit: 10, null: false
    t.integer  "user_id",               null: false
    t.integer  "league_id",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "draft_pick"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name",                          null: false
    t.string   "last_name",                           null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
