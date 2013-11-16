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

ActiveRecord::Schema.define(version: 20131116115059) do

  create_table "days", force: true do |t|
    t.integer  "user_id"
    t.integer  "date"
    t.text     "q1"
    t.text     "q2"
    t.text     "q3"
    t.text     "q4"
    t.boolean  "done"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "mail_done"
  end

  create_table "step_mails", force: true do |t|
    t.integer  "date"
    t.text     "subject"
    t.text     "header"
    t.text     "content"
    t.text     "footer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.boolean  "act"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.string   "password_digest"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
