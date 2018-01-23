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

ActiveRecord::Schema.define(version: 20171205113959) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abstract_authors", force: :cascade do |t|
    t.bigint "author_id"
    t.bigint "abstract_id"
    t.string "author_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["abstract_id"], name: "index_abstract_authors_on_abstract_id"
    t.index ["author_id"], name: "index_abstract_authors_on_author_id"
  end

  create_table "abstracts", force: :cascade do |t|
    t.bigint "corr_author_id"
    t.bigint "pres_author_id"
    t.bigint "reviewer1_id"
    t.bigint "reviewer2_id"
    t.bigint "presentation_id"
    t.integer "session_sequence"
    t.string "abs_title"
    t.string "abs_text"
    t.string "keyword_1"
    t.string "keyword_2"
    t.string "keyword_3"
    t.string "present_request"
    t.string "present_assigned"
    t.string "reviewer1_rec"
    t.string "reviewer2_rec"
    t.string "reviewer1_grade"
    t.string "reviewer2_grade"
    t.string "reviewer1_comment"
    t.string "reviewer2_comment"
    t.boolean "reviewer1_keywords", default: true
    t.boolean "reviewer2_keywords", default: true
    t.boolean "accepted"
    t.boolean "invited"
    t.boolean "paper"
    t.string "admin_final"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["corr_author_id"], name: "index_abstracts_on_corr_author_id"
    t.index ["pres_author_id"], name: "index_abstracts_on_pres_author_id"
    t.index ["presentation_id"], name: "index_abstracts_on_presentation_id"
    t.index ["reviewer1_id"], name: "index_abstracts_on_reviewer1_id"
    t.index ["reviewer2_id"], name: "index_abstracts_on_reviewer2_id"
  end

  create_table "affiliations", force: :cascade do |t|
    t.string "institution"
    t.string "department"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "author_affiliations", force: :cascade do |t|
    t.bigint "author_id"
    t.bigint "affiliation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["affiliation_id"], name: "index_author_affiliations_on_affiliation_id"
    t.index ["author_id"], name: "index_author_affiliations_on_author_id"
  end

  create_table "authors", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "keywords", force: :cascade do |t|
    t.string "keyword_name"
    t.string "keyword_category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "presentations", force: :cascade do |t|
    t.bigint "session_org_id"
    t.bigint "session_chair_id"
    t.bigint "room_id"
    t.string "session_type"
    t.string "session_title"
    t.datetime "session_start"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_presentations_on_room_id"
    t.index ["session_chair_id"], name: "index_presentations_on_session_chair_id"
    t.index ["session_org_id"], name: "index_presentations_on_session_org_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "room_name"
    t.string "room_floor"
    t.string "room_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "username"
    t.string "password"
    t.boolean "submitter"
    t.boolean "reviewer"
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 3, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "abstract_authors", "abstracts"
  add_foreign_key "abstract_authors", "authors"
  add_foreign_key "abstracts", "presentations"
  add_foreign_key "author_affiliations", "affiliations"
  add_foreign_key "author_affiliations", "authors"
  add_foreign_key "presentations", "rooms"
end
