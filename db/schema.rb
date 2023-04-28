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

ActiveRecord::Schema[7.0].define(version: 2023_04_21_140330) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "claims", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "ufn"
    t.string "office_code", null: false
    t.string "status", default: "pending"
    t.jsonb "navigation_stack", default: [], array: true
    t.string "claim_type"
    t.date "rep_order_date"
    t.string "cntp_order"
    t.date "cntp_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "firm_office_id"
    t.boolean "core_costs_exceed_higher_limit"
    t.boolean "enhanced_rates_claimed"
    t.boolean "councel_or_agent_assigned"
    t.boolean "representation_order_withdrawn_on"
    t.date "rep_order_date_withdrawn"
    t.boolean "extradition"
    t.boolean "other"
    t.text "reason_for_claim_other"
    t.uuid "solicitor_id"
    t.index ["firm_office_id"], name: "index_claims_on_firm_office_id"
    t.index ["solicitor_id"], name: "index_claims_on_solicitor_id"
    t.index ["ufn"], name: "index_claims_on_ufn"
  end

  create_table "firm_offices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "account_number"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "town"
    t.string "postcode"
    t.uuid "previous_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["previous_id"], name: "index_firm_offices_on_previous_id"
  end

  create_table "providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "auth_provider", null: false
    t.string "uid", null: false
    t.string "email"
    t.string "description"
    t.string "roles", default: [], null: false, array: true
    t.string "office_codes", default: [], null: false, array: true
    t.jsonb "settings", default: {}, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.index ["auth_provider", "uid"], name: "index_providers_on_auth_provider_and_uid", unique: true
  end

  create_table "solicitors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "full_name"
    t.string "reference_number"
    t.string "contact_full_name"
    t.string "contact_email"
    t.uuid "previous_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["previous_id"], name: "index_solicitors_on_previous_id"
  end

  add_foreign_key "claims", "firm_offices"
  add_foreign_key "claims", "solicitors"
  add_foreign_key "firm_offices", "firm_offices", column: "previous_id"
  add_foreign_key "solicitors", "solicitors", column: "previous_id"
end
