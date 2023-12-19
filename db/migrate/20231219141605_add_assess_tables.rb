class AddAssessTables < ActiveRecord::Migration[7.1]
  def change
    enable_extension "citext"

    create_table "assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.uuid "submitted_claim_id", null: false
      t.uuid "user_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["user_id"], name: "index_assignments_on_user_id"
      t.index ["submitted_claim_id"], name: "index_assignments_on_submitted_claim_id", unique: true
    end

    create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.uuid "submitted_claim_id", null: false
      t.integer "claim_version"
      t.string "event_type"
      t.uuid "primary_user_id"
      t.uuid "secondary_user_id"
      t.string "linked_type"
      t.string "linked_id"
      t.jsonb "details", default: {}
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["linked_type", "linked_id"], name: "index_events_on_linked_type_and_linked_id"
      t.index ["primary_user_id"], name: "index_events_on_primary_user_id"
      t.index ["secondary_user_id"], name: "index_events_on_secondary_user_id"
      t.index ["submitted_claim_id"], name: "index_events_on_submitted_claim_id"
    end

    create_table "submitted_claims", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.string "state"
      t.string "risk"
      t.integer "current_version"
      t.date "received_on"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "json_schema_version"
      t.jsonb "data"
      t.datetime "app_store_updated_at"
      t.string "application_type"
    end

    create_table "versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.uuid "submitted_claim_id"
      t.integer "version"
      t.integer "json_schema_version"
      t.string "state"
      t.jsonb "data"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["submitted_claim_id"], name: "index_versions_on_submitted_claim_id"
    end

    add_foreign_key "assignments", "users"
    add_foreign_key "assignments", "submitted_claims"
    add_foreign_key "events", "users", column: "primary_user_id"
    add_foreign_key "events", "users", column: "secondary_user_id"
    add_foreign_key "events", "submitted_claims"
  end
end
