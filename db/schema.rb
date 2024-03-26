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

ActiveRecord::Schema[7.1].define(version: 2024_03_26_115712) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "additional_costs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "unit_type"
    t.decimal "cost_per_hour", precision: 10, scale: 2
    t.decimal "cost_per_item", precision: 10, scale: 2
    t.integer "items"
    t.integer "period"
    t.uuid "prior_authority_application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "total_cost_allowed", precision: 10, scale: 2
    t.string "adjustment_comment"
    t.index ["prior_authority_application_id"], name: "index_additional_costs_on_prior_authority_application_id"
  end

  create_table "claims", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "ufn"
    t.string "office_code", null: false
    t.string "status", default: "draft"
    t.jsonb "navigation_stack", default: [], array: true
    t.string "claim_type"
    t.date "rep_order_date"
    t.string "cntp_order"
    t.date "cntp_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "firm_office_id"
    t.uuid "solicitor_id"
    t.jsonb "reasons_for_claim", default: []
    t.date "representation_order_withdrawn_date"
    t.text "reason_for_claim_other_details"
    t.string "main_offence"
    t.date "main_offence_date"
    t.string "assigned_counsel"
    t.string "unassigned_counsel"
    t.string "agent_instructed"
    t.string "remitted_to_magistrate"
    t.string "plea"
    t.date "arrest_warrant_date"
    t.date "cracked_trial_date"
    t.date "first_hearing_date"
    t.integer "number_of_hearing"
    t.string "court"
    t.string "in_area"
    t.string "youth_court"
    t.string "hearing_outcome"
    t.string "matter_type"
    t.integer "prosecution_evidence"
    t.integer "defence_statement"
    t.integer "number_of_witnesses"
    t.string "supplemental_claim"
    t.integer "time_spent"
    t.integer "letters"
    t.integer "calls"
    t.integer "calls_uplift"
    t.text "other_info"
    t.text "conclusion"
    t.string "concluded"
    t.string "laa_reference"
    t.integer "letters_uplift"
    t.date "work_before_date"
    t.date "work_after_date"
    t.string "signatory_name"
    t.string "gender"
    t.string "ethnic_group"
    t.string "disability"
    t.boolean "send_by_post"
    t.date "remitted_to_magistrate_date"
    t.string "preparation_time"
    t.string "work_before"
    t.string "work_after"
    t.string "has_disbursements"
    t.uuid "submitter_id"
    t.string "is_other_info"
    t.string "answer_equality"
    t.datetime "app_store_updated_at"
    t.string "plea_category"
    t.float "submitted_total"
    t.float "submitted_total_inc_vat"
    t.float "adjusted_total"
    t.float "adjusted_total_inc_vat"
    t.index ["firm_office_id"], name: "index_claims_on_firm_office_id"
    t.index ["solicitor_id"], name: "index_claims_on_solicitor_id"
    t.index ["ufn"], name: "index_claims_on_ufn"
  end

  create_table "cost_totals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "claim_id", null: false
    t.string "cost_type", null: false
    t.float "amount", null: false
    t.float "amount_with_vat"
    t.index ["claim_id"], name: "index_cost_totals_on_claim_id"
  end

  create_table "defendants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "maat"
    t.integer "position"
    t.boolean "main", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "defendable_id", null: false
    t.string "defendable_type", null: false
    t.string "first_name"
    t.string "last_name"
    t.date "date_of_birth"
  end

  create_table "disbursements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "claim_id", null: false
    t.date "disbursement_date"
    t.string "disbursement_type"
    t.string "other_type"
    t.decimal "miles", precision: 10, scale: 3
    t.decimal "total_cost_without_vat", precision: 10, scale: 2
    t.text "details"
    t.string "prior_authority"
    t.string "apply_vat"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "vat_amount", precision: 10, scale: 2
    t.index ["claim_id"], name: "index_disbursements_on_claim_id"
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
    t.string "vat_registered"
    t.index ["previous_id"], name: "index_firm_offices_on_previous_id"
  end

  create_table "further_informations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "information_requested"
    t.string "information_supplied"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "prior_authority_application_id", null: false
    t.uuid "caseworker_id"
    t.datetime "requested_at"
    t.datetime "expired_at"
    t.index ["prior_authority_application_id"], name: "index_further_informations_on_prior_authority_application_id"
  end

  create_table "prior_authority_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "provider_id"
    t.uuid "firm_office_id"
    t.uuid "solicitor_id"
    t.string "office_code", null: false
    t.boolean "prison_law"
    t.boolean "authority_value"
    t.string "ufn"
    t.string "laa_reference"
    t.string "status", default: "pre_draft"
    t.jsonb "navigation_stack", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "next_hearing"
    t.date "next_hearing_date"
    t.string "plea"
    t.string "court_type"
    t.boolean "youth_court"
    t.boolean "psychiatric_liaison"
    t.string "psychiatric_liaison_reason_not"
    t.date "rep_order_date"
    t.boolean "client_detained"
    t.boolean "subject_to_poca"
    t.text "reason_why"
    t.boolean "additional_costs_still_to_add"
    t.boolean "prior_authority_granted"
    t.text "no_alternative_quote_reason"
    t.boolean "alternative_quotes_still_to_add"
    t.string "service_type"
    t.string "custom_service_name"
    t.string "main_offence_id"
    t.string "custom_main_offence_name"
    t.string "prison_id"
    t.string "custom_prison_name"
    t.datetime "app_store_updated_at"
    t.string "assessment_comment"
    t.datetime "resubmission_requested"
    t.datetime "resubmission_deadline"
    t.index ["firm_office_id"], name: "index_prior_authority_applications_on_firm_office_id"
    t.index ["provider_id"], name: "index_prior_authority_applications_on_provider_id"
    t.index ["solicitor_id"], name: "index_prior_authority_applications_on_solicitor_id"
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

  create_table "quotes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "contact_full_name"
    t.string "organisation"
    t.string "postcode"
    t.boolean "primary", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "prior_authority_application_id", null: false
    t.boolean "ordered_by_court"
    t.boolean "related_to_post_mortem"
    t.string "user_chosen_cost_type"
    t.decimal "cost_per_hour", precision: 10, scale: 2
    t.decimal "cost_per_item", precision: 10, scale: 2
    t.integer "items"
    t.integer "period"
    t.integer "travel_time"
    t.decimal "travel_cost_per_hour", precision: 10, scale: 2
    t.text "travel_cost_reason"
    t.text "additional_cost_list"
    t.decimal "additional_cost_total", precision: 10, scale: 2
    t.decimal "base_cost_allowed", precision: 10, scale: 2
    t.decimal "travel_cost_allowed", precision: 10, scale: 2
    t.string "service_adjustment_comment"
    t.string "travel_adjustment_comment"
    t.index ["prior_authority_application_id"], name: "index_quotes_on_prior_authority_application_id"
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

  create_table "supporting_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "documentable_id", null: false
    t.string "file_name"
    t.string "file_type"
    t.integer "file_size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file_path"
    t.string "documentable_type"
    t.string "document_type"
    t.index ["documentable_id"], name: "index_supporting_documents_on_documentable_id"
    t.index ["documentable_type", "documentable_id"], name: "idx_on_documentable_type_documentable_id_ab3e47fb9f"
  end

  create_table "work_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "claim_id", null: false
    t.string "work_type"
    t.integer "time_spent"
    t.date "completed_on"
    t.string "fee_earner"
    t.integer "uplift"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["claim_id"], name: "index_work_items_on_claim_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "additional_costs", "prior_authority_applications"
  add_foreign_key "claims", "firm_offices"
  add_foreign_key "claims", "providers", column: "submitter_id"
  add_foreign_key "claims", "solicitors"
  add_foreign_key "cost_totals", "claims"
  add_foreign_key "disbursements", "claims"
  add_foreign_key "firm_offices", "firm_offices", column: "previous_id"
  add_foreign_key "further_informations", "prior_authority_applications"
  add_foreign_key "prior_authority_applications", "firm_offices"
  add_foreign_key "prior_authority_applications", "solicitors"
  add_foreign_key "quotes", "prior_authority_applications"
  add_foreign_key "solicitors", "solicitors", column: "previous_id"
  add_foreign_key "work_items", "claims"
end
