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

ActiveRecord::Schema.define(version: 20200331121451) do

  create_table "acquisitions", force: :cascade do |t|
    t.integer "crm_id"
    t.string "company"
    t.string "day"
    t.string "name"
    t.string "statu"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["crm_id"], name: "index_acquisitions_on_crm_id"
  end

  create_table "admins", force: :cascade do |t|
    t.string "user_name", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "select"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "calls", force: :cascade do |t|
    t.string "statu"
    t.datetime "time"
    t.string "comment"
    t.integer "customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "admin_id"
    t.integer "crm_id"
    t.integer "customer_tel_id"
    t.integer "user_id"
    t.index ["admin_id"], name: "index_calls_on_admin_id"
    t.index ["crm_id"], name: "index_calls_on_crm_id"
    t.index ["customer_id"], name: "index_calls_on_customer_id"
    t.index ["customer_tel_id"], name: "index_calls_on_customer_tel_id"
    t.index ["user_id"], name: "index_calls_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "crm_id"
    t.string "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["crm_id"], name: "index_comments_on_crm_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "crms", force: :cascade do |t|
    t.string "company"
    t.string "first_name"
    t.string "last_name"
    t.string "first_kana"
    t.string "last_kana"
    t.string "tel"
    t.string "mobile"
    t.string "fax"
    t.string "mail"
    t.string "postnumber"
    t.string "prefecture"
    t.string "city"
    t.string "town"
    t.string "building"
    t.string "item"
    t.string "statu"
    t.string "price"
    t.string "number"
    t.string "history"
    t.string "area"
    t.string "target"
    t.string "next"
    t.string "content"
    t.string "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string "company"
    t.string "store"
    t.string "first_name"
    t.string "last_name"
    t.string "first_kana"
    t.string "last_kana"
    t.string "tel"
    t.string "tel2"
    t.string "fax"
    t.string "mobile"
    t.string "industry"
    t.string "mail"
    t.string "url"
    t.string "people"
    t.string "postnumber"
    t.string "address"
    t.string "caption"
    t.string "remarks"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "memo_1"
    t.string "memo_2"
    t.string "memo_3"
    t.string "memo_4"
    t.string "memo_5"
    t.string "choice"
    t.string "old_date"
    t.string "title"
    t.string "old_statu"
    t.string "other"
    t.string "url_2"
    t.string "extraction_date"
  end

  create_table "customers_search_orders", force: :cascade do |t|
    t.integer "admin_id"
    t.integer "customer_id"
    t.integer "prev_customer_id"
    t.integer "next_customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "images", force: :cascade do |t|
    t.integer "crm_id"
    t.string "name"
    t.string "views"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["crm_id"], name: "index_images_on_crm_id"
  end

  create_table "knowledges", force: :cascade do |t|
    t.string "title"
    t.string "select"
    t.string "name"
    t.string "answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "progresses", force: :cascade do |t|
    t.integer "crm_id"
    t.string "statu"
    t.string "price"
    t.string "number"
    t.string "history"
    t.string "area"
    t.string "target"
    t.string "next"
    t.string "content"
    t.string "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["crm_id"], name: "index_progresses_on_crm_id"
  end

  create_table "smartphone_logs", force: :cascade do |t|
    t.string "token", null: false
    t.string "log_data", null: false
    t.datetime "created_at", null: false
  end

  create_table "smartphones", force: :cascade do |t|
    t.string "device_name", null: false
    t.string "token", null: false
    t.boolean "delete_flag", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "upload_data", force: :cascade do |t|
    t.string "name"
    t.string "file"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_upload_data_on_company_id"
  end

  create_table "upload_files", force: :cascade do |t|
    t.string "name"
    t.string "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "user_name", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "select"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
