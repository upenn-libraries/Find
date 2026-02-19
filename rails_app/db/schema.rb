# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_12_184947) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "alerts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "on"
    t.string "scope"
    t.text "text"
    t.datetime "updated_at", null: false
  end

  create_table "bookmarks", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "document_id"
    t.string "document_type"
    t.binary "title"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id", null: false
    t.string "user_type"
    t.index ["document_id"], name: "index_bookmarks_on_document_id"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "discover_art_works", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "creator"
    t.string "description"
    t.string "format"
    t.string "identifier"
    t.string "link"
    t.string "location"
    t.string "thumbnail_url"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "discover_artifacts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "creator"
    t.string "description"
    t.string "format"
    t.string "identifier"
    t.string "link"
    t.string "location"
    t.boolean "on_display"
    t.string "other_values", default: [], array: true
    t.string "thumbnail_url"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "discover_harvests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "etag"
    t.datetime "resource_last_modified"
    t.string "source"
    t.datetime "updated_at", null: false
    t.index ["source"], name: "index_discover_harvests_on_source", unique: true
  end

  create_table "searches", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.binary "query_params"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.string "user_type"
    t.index ["user_id"], name: "index_searches_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.boolean "guest", default: false, null: false
    t.string "ils_group"
    t.string "provider"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end
end
