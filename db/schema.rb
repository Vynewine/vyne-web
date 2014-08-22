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

ActiveRecord::Schema.define(version: 20140820151210) do

  create_table "allergies", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "allergies_wines", id: false, force: true do |t|
    t.integer  "allergy_id", null: false
    t.integer  "wine_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "allergies_wines", ["allergy_id"], name: "index_allergies_wines_on_allergy_id"
  add_index "allergies_wines", ["wine_id"], name: "index_allergies_wines_on_wine_id"

  create_table "appellations", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bottlings", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", force: true do |t|
    t.string   "name"
    t.string   "alpha_2"
    t.string   "alpha_3"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "foods", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "foods_wines", id: false, force: true do |t|
    t.integer  "food_id",    null: false
    t.integer  "wine_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "foods_wines", ["food_id"], name: "index_foods_wines_on_food_id"
  add_index "foods_wines", ["wine_id"], name: "index_foods_wines_on_wine_id"

  create_table "grapenames", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grapes", force: true do |t|
    t.integer  "grapename_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grapes_wines", id: false, force: true do |t|
    t.integer  "grape_id",   null: false
    t.integer  "wine_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "grapes_wines", ["grape_id"], name: "index_grapes_wines_on_grape_id"
  add_index "grapes_wines", ["wine_id"], name: "index_grapes_wines_on_wine_id"

  create_table "maturations", force: true do |t|
    t.integer  "bottling_id"
    t.integer  "period"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notes", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notes_wines", id: false, force: true do |t|
    t.integer  "note_id",    null: false
    t.integer  "wine_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes_wines", ["note_id"], name: "index_notes_wines_on_note_id"
  add_index "notes_wines", ["wine_id"], name: "index_notes_wines_on_wine_id"

  create_table "occasions", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "occasions_wines", id: false, force: true do |t|
    t.integer  "occasion_id", null: false
    t.integer  "wine_id",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "occasions_wines", ["occasion_id"], name: "index_occasions_wines_on_occasion_id"
  add_index "occasions_wines", ["wine_id"], name: "index_occasions_wines_on_wine_id"

  create_table "producers", force: true do |t|
    t.string   "name"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "regions", force: true do |t|
    t.string   "name"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subregions", force: true do |t|
    t.string   "name"
    t.integer  "region_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "types_wines", id: false, force: true do |t|
    t.integer  "type_id",    null: false
    t.integer  "wine_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "types_wines", ["type_id"], name: "index_types_wines_on_type_id"
  add_index "types_wines", ["wine_id"], name: "index_types_wines_on_wine_id"

  create_table "wines", force: true do |t|
    t.string   "name"
    t.integer  "vintage"
    t.string   "area"
    t.boolean  "single_estate"
    t.integer  "alcohol"
    t.integer  "sugar"
    t.integer  "acidity"
    t.integer  "ph"
    t.boolean  "vegetarian"
    t.boolean  "vegan"
    t.boolean  "organic"
    t.integer  "producer_id"
    t.integer  "subregion_id"
    t.integer  "appellation_id"
    t.integer  "maturation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
