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

ActiveRecord::Schema[7.0].define(version: 2023_04_07_083940) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "claims", force: :cascade do |t|
    t.string "guid"
    t.string "usn"
    t.string "account_no"
    t.string "provider_no"
    t.boolean "assigned_counsel"
    t.string "rep_order"
    t.string "cntp_number"
    t.datetime "rep_date"
    t.datetime "cntp_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "provider_offices", force: :cascade do |t|
    t.string "guid"
    t.string "acccount_no"
    t.string "firm_name"
    t.string "address_line1"
    t.string "address_line2"
    t.string "town"
    t.string "postcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "provider_solicitors", force: :cascade do |t|
    t.string "guid"
    t.string "provider"
    t.string "number"
    t.string "email"
    t.string "reference_number"
    t.string "first_name"
    t.string "last_name"
    t.string "contact_name"
    t.string "contact_tel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
