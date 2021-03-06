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

ActiveRecord::Schema.define(version: 20170718214619) do

  create_table "auctions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.integer  "user_id"
    t.integer  "auctioneers_number",            default: 1000
    t.float    "price",              limit: 24, default: 0.0,    null: false
    t.datetime "due_date",                                       null: false
    t.integer  "nrc",                                            null: false
    t.string   "auction_type",                  default: "good"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "winner"
    t.string   "participants",       limit: 45, default: "0"
    t.index ["user_id"], name: "index_auctions_on_user_id", using: :btree
  end

  create_table "comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "offer_id"
    t.integer  "user_id"
    t.text     "content",     limit: 65535, null: false
    t.float    "price_offer", limit: 24,    null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["offer_id"], name: "index_comments_on_offer_id", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

  create_table "group_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "group_id"
    t.integer  "product_id"
    t.integer  "product_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "loan_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "type_name"
    t.integer  "amount"
    t.integer  "interest"
    t.integer  "fees"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "recipient_id"
    t.integer  "actor_id"
    t.integer  "secondactor_id"
    t.datetime "read_at"
    t.string   "action"
    t.integer  "notifiable_id"
    t.string   "notifiable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "offers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.integer  "user_id"
    t.integer  "quantity",              default: 1
    t.float    "price",      limit: 24, default: 0.0,    null: false
    t.datetime "due_date",                               null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "nrc",                                    null: false
    t.string   "offer_type", limit: 45, default: "good", null: false
  end

  create_table "product_groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "group_name"
    t.integer  "nrc"
    t.integer  "exam_total"
    t.integer  "lab_total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.string   "elemento"
    t.integer  "nrc"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "product_type", limit: 45, default: "good", null: false
    t.integer  "offer_id",                                 null: false
    t.index ["offer_id"], name: "fk_products_1_idx", using: :btree
  end

  create_table "registration_keys", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "validations"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "status_loans", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "student_id"
    t.integer  "nrc"
    t.integer  "loan_stat"
    t.integer  "type_id"
    t.integer  "amount"
    t.integer  "next_payment"
    t.integer  "current_fee",  default: 0
    t.datetime "starting_in"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "subject_nrcs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "subject_id"
    t.integer  "nrc"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_id"], name: "index_subject_nrcs_on_subject_id", using: :btree
  end

  create_table "subjects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_subjects_on_user_id", using: :btree
  end

  create_table "transactions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "user_to",                                null: false
    t.float    "amount",       limit: 24,                null: false
    t.text     "observations", limit: 65535
    t.integer  "nrc"
    t.integer  "auth",                       default: 2, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.index ["user_id"], name: "index_transactions_on_user_id", using: :btree
  end

  create_table "user_subjects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "subject_id"
    t.float    "budget",     limit: 24, default: 0.0
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["subject_id"], name: "index_user_subjects_on_subject_id", using: :btree
    t.index ["user_id"], name: "index_user_subjects_on_user_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",                                                      null: false
    t.string   "last_name",                                                 null: false
    t.integer  "codigo",                                                    null: false
    t.boolean  "teacher",                           default: false
    t.float    "saldo",                  limit: 24, default: 0.0,           null: false
    t.string   "email",                             default: "",            null: false
    t.string   "encrypted_password",                default: "",            null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,             null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "skin",                              default: "skin-purple"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "superadmin",                        default: false
    t.index ["codigo"], name: "index_users_on_codigo", unique: true, using: :btree
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "auctions", "users"
  add_foreign_key "comments", "offers"
  add_foreign_key "comments", "users"
  add_foreign_key "subject_nrcs", "subjects"
  add_foreign_key "subjects", "users"
  add_foreign_key "transactions", "users"
  add_foreign_key "user_subjects", "users"
end
