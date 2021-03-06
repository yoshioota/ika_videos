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

ActiveRecord::Schema.define(version: 0) do

  create_table "captures", force: :cascade do |t|
    t.string   "title",                           limit: 255
    t.integer  "total_frames",                    limit: 8
    t.string   "duration",                        limit: 255
    t.string   "full_path",                       limit: 255
    t.boolean  "exist"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "compute_total_frames_started_at"
    t.datetime "compute_total_frames_ended_at"
    t.datetime "create_thumbnails_started_at"
    t.datetime "create_thumbnails_ended_at"
    t.datetime "create_markers_started_at"
    t.datetime "create_markers_ended_at"
    t.datetime "analyze_videos_started_at"
    t.datetime "analyze_videos_ended_at"
    t.integer  "markers_count",                   limit: 4,   default: 0
    t.integer  "videos_count",                    limit: 4,   default: 0
    t.boolean  "visible",                                     default: true
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
  end

  add_index "captures", ["updated_at"], name: "index_captures_on_updated_at", using: :btree

  create_table "credentials", force: :cascade do |t|
    t.string   "client_id",     limit: 255
    t.string   "client_secret", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "game_results", force: :cascade do |t|
    t.string   "result_type",   limit: 255
    t.string   "span_type",     limit: 255
    t.string   "date_on",       limit: 255
    t.string   "rule",          limit: 255
    t.string   "stage",         limit: 255
    t.integer  "wins",          limit: 4
    t.integer  "losses",        limit: 4
    t.float    "win_loss_rate", limit: 24
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "game_results", ["result_type"], name: "index_game_results_on_result_type", using: :btree
  add_index "game_results", ["rule"], name: "index_game_results_on_rule", using: :btree
  add_index "game_results", ["stage"], name: "index_game_results_on_stage", using: :btree
  add_index "game_results", ["win_loss_rate"], name: "index_game_results_on_win_loss_rate", using: :btree

  create_table "markers", force: :cascade do |t|
    t.integer  "capture_id",  limit: 4,                            null: false
    t.integer  "total_frame", limit: 8,                            null: false
    t.string   "marker_type", limit: 255,                          null: false
    t.string   "description", limit: 255
    t.decimal  "min_score",               precision: 21, scale: 1, null: false
    t.decimal  "max_score",               precision: 21, scale: 1, null: false
    t.integer  "min_point_x", limit: 4
    t.integer  "min_point_y", limit: 4
    t.integer  "max_point_x", limit: 4
    t.integer  "max_point_y", limit: 4
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  add_index "markers", ["capture_id"], name: "index_markers_on_capture_id", using: :btree
  add_index "markers", ["marker_type"], name: "index_markers_on_marker_type", using: :btree
  add_index "markers", ["total_frame"], name: "index_markers_on_total_frame", using: :btree

  create_table "playlists", force: :cascade do |t|
    t.string   "youtube_id",             limit: 255
    t.string   "title",                  limit: 255
    t.date     "date_on"
    t.integer  "playlists_videos_count", limit: 4,   default: 0
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  create_table "playlists_videos", force: :cascade do |t|
    t.string   "youtube_id",  limit: 255
    t.integer  "playlist_id", limit: 4,                  null: false
    t.integer  "video_id",    limit: 4,                  null: false
    t.integer  "order_no",    limit: 4,   default: 9999
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "playlists_videos", ["playlist_id", "video_id", "order_no"], name: "idx1", using: :btree

  create_table "videos", force: :cascade do |t|
    t.integer  "capture_id",   limit: 4
    t.integer  "total_frames", limit: 4
    t.integer  "start_frame",  limit: 4
    t.integer  "end_frame",    limit: 4
    t.string   "youtube_id",   limit: 255
    t.datetime "started_at"
    t.datetime "ended_at"
    t.string   "file_name",    limit: 255
    t.string   "game_rule",    limit: 255
    t.string   "game_stage",   limit: 255
    t.string   "game_result",  limit: 255
    t.integer  "kills",        limit: 4
    t.integer  "deaths",       limit: 4
    t.string   "rank_str",     limit: 255
    t.integer  "rank_no",      limit: 4
    t.integer  "rank_points",  limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "videos", ["capture_id"], name: "index_videos_on_capture_id", using: :btree
  add_index "videos", ["game_result"], name: "index_videos_on_game_result", using: :btree
  add_index "videos", ["game_rule"], name: "index_videos_on_game_rule", using: :btree
  add_index "videos", ["game_stage"], name: "index_videos_on_game_stage", using: :btree
  add_index "videos", ["started_at"], name: "index_videos_on_started_at", using: :btree

end
