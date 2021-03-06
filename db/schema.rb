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

ActiveRecord::Schema.define(version: 20180826155252) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "draft_statuses", id: :serial, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leagues", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "sport_id", null: false
    t.string "password", null: false
    t.integer "size", null: false
    t.integer "rounds", null: false
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "draft_status_id"
    t.index ["draft_status_id"], name: "index_leagues_on_draft_status_id"
    t.index ["sport_id"], name: "index_leagues_on_sport_id"
    t.index ["user_id"], name: "index_leagues_on_user_id"
  end

  create_table "picks", id: :serial, force: :cascade do |t|
    t.integer "overall_pick", null: false
    t.integer "player_id"
    t.integer "round", null: false
    t.integer "round_pick", null: false
    t.integer "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "keeper", default: false, null: false
    t.index ["keeper"], name: "index_picks_on_keeper"
    t.index ["overall_pick"], name: "index_picks_on_overall_pick"
    t.index ["player_id"], name: "index_picks_on_player_id"
    t.index ["team_id"], name: "index_picks_on_team_id"
  end

  create_table "players", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "last_name", null: false
    t.string "position", null: false
    t.string "team", null: false
    t.text "injury"
    t.text "headline"
    t.text "photo_url"
    t.string "sport_id", null: false
    t.string "pro_status"
    t.string "orig_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_players_on_deleted_at"
    t.index ["sport_id"], name: "index_players_on_sport_id"
  end

  create_table "sports", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "positions", default: [], array: true
  end

  create_table "teams", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "short_name", limit: 10, null: false
    t.integer "user_id", null: false
    t.integer "league_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "draft_pick"
    t.index ["league_id"], name: "index_teams_on_league_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
