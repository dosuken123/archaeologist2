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

ActiveRecord::Schema.define(version: 20150818025521) do

  create_table "histories", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.integer  "task_id"
    t.integer  "is_off",     default: 0, null: false
    t.integer  "del_flg",    default: 0, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "histories", ["project_id"], name: "index_histories_on_project_id"
  add_index "histories", ["task_id"], name: "index_histories_on_task_id"
  add_index "histories", ["user_id"], name: "index_histories_on_user_id"

  create_table "projects", force: :cascade do |t|
    t.text     "project_name"
    t.text     "icon_path"
    t.integer  "del_flg",      default: 0, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.text     "task_name"
    t.integer  "task_status", default: 0, null: false
    t.text     "memo"
    t.integer  "del_flg",     default: 0, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "tasks", ["project_id"], name: "index_tasks_on_project_id"
  add_index "tasks", ["user_id"], name: "index_tasks_on_user_id"

  create_table "users", force: :cascade do |t|
    t.text     "user_name",                         null: false
    t.text     "icon_path"
    t.text     "background_image_path"
    t.integer  "del_flg",               default: 0, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

end
