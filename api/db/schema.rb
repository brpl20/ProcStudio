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

ActiveRecord::Schema[8.0].define(version: 2025_09_29_111938) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
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

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "zip_code", null: false
    t.string "street", null: false
    t.string "number"
    t.string "complement"
    t.string "neighborhood"
    t.string "city", null: false
    t.string "state", null: false
    t.string "addressable_type", null: false
    t.bigint "addressable_id", null: false
    t.string "address_type", default: "main"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
    t.index ["city", "state"], name: "index_addresses_on_city_and_state"
    t.index ["deleted_at"], name: "index_addresses_on_deleted_at"
    t.index ["zip_code"], name: "index_addresses_on_zip_code"
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.string "bank_name"
    t.string "agency"
    t.string "account"
    t.string "operation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pix"
    t.string "bankable_type"
    t.bigint "bankable_id"
    t.datetime "deleted_at"
    t.string "account_type", default: "main"
    t.index ["bankable_type", "bankable_id"], name: "index_bank_accounts_on_bankable"
    t.index ["deleted_at"], name: "index_bank_accounts_on_deleted_at"
  end

  create_table "compliance_notifications", force: :cascade do |t|
    t.string "notification_type", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.string "status", default: "pending", null: false
    t.string "resource_type"
    t.bigint "resource_id"
    t.json "metadata"
    t.datetime "resolved_at"
    t.datetime "ignored_at"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_id", null: false
    t.index ["notification_type"], name: "index_compliance_notifications_on_notification_type"
    t.index ["resource_type", "resource_id"], name: "idx_on_resource_type_resource_id_a14cb9f6d9"
    t.index ["status"], name: "index_compliance_notifications_on_status"
    t.index ["team_id"], name: "index_compliance_notifications_on_team_id"
    t.index ["user_id"], name: "index_compliance_notifications_on_user_id"
  end

  create_table "customer_bank_accounts", force: :cascade do |t|
    t.bigint "profile_customer_id", null: false
    t.bigint "bank_account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["bank_account_id"], name: "index_customer_bank_accounts_on_bank_account_id"
    t.index ["deleted_at"], name: "index_customer_bank_accounts_on_deleted_at"
    t.index ["profile_customer_id"], name: "index_customer_bank_accounts_on_profile_customer_id"
  end

  create_table "customer_emails", force: :cascade do |t|
    t.bigint "profile_customer_id", null: false
    t.bigint "email_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_customer_emails_on_deleted_at"
    t.index ["email_id"], name: "index_customer_emails_on_email_id"
    t.index ["profile_customer_id"], name: "index_customer_emails_on_profile_customer_id"
  end

  create_table "customer_files", force: :cascade do |t|
    t.string "file_description"
    t.bigint "profile_customer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "file_s3_key"
    t.index ["deleted_at"], name: "index_customer_files_on_deleted_at"
    t.index ["profile_customer_id"], name: "index_customer_files_on_profile_customer_id"
  end

  create_table "customer_works", force: :cascade do |t|
    t.bigint "profile_customer_id", null: false
    t.bigint "work_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_customer_works_on_deleted_at"
    t.index ["profile_customer_id"], name: "index_customer_works_on_profile_customer_id"
    t.index ["work_id"], name: "index_customer_works_on_work_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "jwt_token"
    t.bigint "created_by_id"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "unconfirmed_email"
    t.string "status", default: "active", null: false
    t.index ["confirmation_token"], name: "index_customers_on_confirmation_token", unique: true
    t.index ["created_by_id"], name: "index_customers_on_created_by_id"
    t.index ["deleted_at"], name: "index_customers_on_deleted_at"
    t.index ["email"], name: "index_customers_on_email_not_deleted", where: "(deleted_at IS NULL)"
    t.index ["reset_password_token"], name: "index_customers_on_reset_password_token", unique: true
  end

  create_table "documents", force: :cascade do |t|
    t.string "document_type"
    t.bigint "work_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "profile_customer_id"
    t.datetime "deleted_at"
    t.integer "format", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.integer "sign_source", default: 0, null: false
    t.string "original_s3_key"
    t.string "signed_s3_key"
    t.index ["deleted_at"], name: "index_documents_on_deleted_at"
    t.index ["profile_customer_id"], name: "index_documents_on_profile_customer_id"
    t.index ["work_id"], name: "index_documents_on_work_id"
  end

  create_table "draft_works", force: :cascade do |t|
    t.string "name"
    t.bigint "work_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_draft_works_on_deleted_at"
    t.index ["work_id"], name: "index_draft_works_on_work_id"
  end

  create_table "drafts", force: :cascade do |t|
    t.string "draftable_type", null: false
    t.bigint "draftable_id"
    t.bigint "user_id"
    t.bigint "customer_id"
    t.string "form_type", null: false
    t.json "data", null: false
    t.string "status", default: "draft"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_id"
    t.index ["customer_id"], name: "index_drafts_on_customer_id"
    t.index ["draftable_type", "draftable_id"], name: "index_drafts_on_draftable"
    t.index ["expires_at"], name: "index_drafts_on_expires_at"
    t.index ["status"], name: "index_drafts_on_status"
    t.index ["team_id", "draftable_type", "draftable_id", "form_type"], name: "index_drafts_unique_existing_records", unique: true, where: "(draftable_id IS NOT NULL)"
    t.index ["team_id", "user_id", "form_type", "draftable_type"], name: "index_drafts_new_records", where: "(draftable_id IS NULL)"
    t.index ["team_id"], name: "index_drafts_on_team_id"
    t.index ["user_id"], name: "index_drafts_on_user_id"
  end

  create_table "emails", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "emailable_type"
    t.bigint "emailable_id"
    t.datetime "deleted_at"
    t.string "email_type", default: "main"
    t.index ["deleted_at"], name: "index_emails_on_deleted_at"
    t.index ["emailable_type", "emailable_id"], name: "index_emails_on_emailable"
  end

  create_table "honoraries", force: :cascade do |t|
    t.string "fixed_honorary_value"
    t.string "parcelling_value"
    t.string "honorary_type"
    t.string "percent_honorary_value"
    t.boolean "parcelling"
    t.bigint "work_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "work_prev"
    t.bigint "procedure_id"
    t.string "name"
    t.text "description"
    t.string "status", default: "active"
    t.index ["deleted_at"], name: "index_honoraries_on_deleted_at"
    t.index ["procedure_id"], name: "index_honoraries_on_procedure_id"
    t.index ["status"], name: "index_honoraries_on_status"
    t.index ["work_id", "procedure_id"], name: "index_honoraries_on_work_id_and_procedure_id"
    t.index ["work_id"], name: "index_honoraries_on_work_id"
    t.check_constraint "work_id IS NOT NULL AND procedure_id IS NULL OR work_id IS NOT NULL AND procedure_id IS NOT NULL", name: "check_honorary_attachment"
  end

  create_table "honorary_components", force: :cascade do |t|
    t.bigint "honorary_id", null: false
    t.string "component_type", null: false
    t.jsonb "details", default: {}, null: false
    t.boolean "active", default: true
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_type"], name: "index_honorary_components_on_component_type"
    t.index ["details"], name: "index_honorary_components_on_details", using: :gin
    t.index ["honorary_id", "component_type", "active"], name: "index_honorary_components_lookup"
    t.index ["honorary_id"], name: "index_honorary_components_on_honorary_id"
    t.index ["position"], name: "index_honorary_components_on_position"
  end

  create_table "job_comments", force: :cascade do |t|
    t.text "content", null: false
    t.bigint "user_profile_id", null: false
    t.bigint "job_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_job_comments_on_deleted_at"
    t.index ["job_id", "created_at"], name: "index_job_comments_on_job_id_and_created_at"
    t.index ["job_id"], name: "index_job_comments_on_job_id"
    t.index ["user_profile_id"], name: "index_job_comments_on_user_profile_id"
  end

  create_table "job_user_profiles", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "user_profile_id", null: false
    t.string "role", default: "assignee"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_job_user_profiles_on_deleted_at"
    t.index ["job_id", "user_profile_id"], name: "index_job_user_profiles_on_job_id_and_user_profile_id", unique: true
    t.index ["job_id"], name: "index_job_user_profiles_on_job_id"
    t.index ["user_profile_id"], name: "index_job_user_profiles_on_user_profile_id"
  end

  create_table "job_works", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "work_id", null: false
    t.bigint "user_profile_id", null: false
    t.bigint "profile_customer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_job_works_on_job_id"
    t.index ["profile_customer_id"], name: "index_job_works_on_profile_customer_id"
    t.index ["user_profile_id"], name: "index_job_works_on_user_profile_id"
    t.index ["work_id"], name: "index_job_works_on_work_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.string "description"
    t.date "deadline", null: false
    t.string "status"
    t.string "priority"
    t.string "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "work_id"
    t.bigint "profile_customer_id"
    t.bigint "created_by_id"
    t.datetime "deleted_at"
    t.bigint "team_id", null: false
    t.index ["created_by_id"], name: "index_jobs_on_created_by_id"
    t.index ["deleted_at"], name: "index_jobs_on_deleted_at"
    t.index ["profile_customer_id"], name: "index_jobs_on_profile_customer_id"
    t.index ["team_id"], name: "index_jobs_on_team_id"
    t.index ["work_id"], name: "index_jobs_on_work_id"
  end

  create_table "law_areas", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.text "description"
    t.boolean "active", default: true, null: false
    t.integer "sort_order", default: 0
    t.bigint "parent_area_id"
    t.bigint "created_by_team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_law_areas_on_active"
    t.index ["code", "created_by_team_id", "parent_area_id"], name: "index_law_areas_unique_code", unique: true
    t.index ["created_by_team_id"], name: "index_law_areas_on_created_by_team_id"
    t.index ["parent_area_id"], name: "index_law_areas_on_parent_area_id"
  end

  create_table "legal_cost_entries", force: :cascade do |t|
    t.bigint "legal_cost_id", null: false
    t.string "cost_type", null: false
    t.string "name", null: false
    t.text "description"
    t.decimal "amount", precision: 10, scale: 2
    t.boolean "estimated", default: false
    t.boolean "paid", default: false
    t.date "due_date"
    t.date "payment_date"
    t.string "receipt_number"
    t.string "payment_method"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "legal_cost_type_id"
    t.index ["cost_type"], name: "index_legal_cost_entries_on_cost_type"
    t.index ["due_date"], name: "index_legal_cost_entries_on_due_date"
    t.index ["legal_cost_id", "paid"], name: "index_legal_cost_entries_on_legal_cost_id_and_paid"
    t.index ["legal_cost_id"], name: "index_legal_cost_entries_on_legal_cost_id"
    t.index ["legal_cost_type_id"], name: "index_legal_cost_entries_on_legal_cost_type_id"
    t.index ["payment_date"], name: "index_legal_cost_entries_on_payment_date"
  end

  create_table "legal_cost_types", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.text "description"
    t.string "category"
    t.boolean "active", default: true
    t.boolean "is_system", default: false, null: false
    t.bigint "team_id"
    t.integer "display_order"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_legal_cost_types_on_active"
    t.index ["category"], name: "index_legal_cost_types_on_category"
    t.index ["display_order"], name: "index_legal_cost_types_on_display_order"
    t.index ["is_system"], name: "index_legal_cost_types_on_is_system"
    t.index ["key", "team_id"], name: "index_legal_cost_types_on_key_and_team_id", unique: true
    t.index ["team_id"], name: "index_legal_cost_types_on_team_id"
  end

  create_table "legal_costs", force: :cascade do |t|
    t.bigint "honorary_id", null: false
    t.boolean "client_responsible", default: true
    t.boolean "include_in_invoices", default: true
    t.decimal "admin_fee_percentage", precision: 5, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["honorary_id"], name: "index_legal_costs_on_honorary_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "title"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "body"
    t.string "notification_type"
    t.jsonb "data", default: {}
    t.string "action_url"
    t.string "sender_type"
    t.bigint "sender_id"
    t.bigint "user_profile_id"
    t.bigint "team_id", null: false
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["notification_type"], name: "index_notifications_on_notification_type"
    t.index ["read"], name: "index_notifications_on_read"
    t.index ["sender_type", "sender_id"], name: "index_notifications_on_sender_type_and_sender_id"
    t.index ["team_id"], name: "index_notifications_on_team_id"
    t.index ["user_profile_id"], name: "index_notifications_on_user_profile_id"
  end

  create_table "office_attachment_metadata", force: :cascade do |t|
    t.bigint "office_id", null: false
    t.date "document_date"
    t.string "document_type"
    t.string "description"
    t.json "custom_metadata"
    t.bigint "uploaded_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "s3_key"
    t.string "filename"
    t.string "content_type"
    t.bigint "byte_size"
    t.index ["document_type"], name: "index_office_attachment_metadata_on_document_type"
    t.index ["office_id", "document_type"], name: "idx_on_office_id_document_type_167734bb2a"
    t.index ["office_id"], name: "index_office_attachment_metadata_on_office_id"
    t.index ["s3_key"], name: "index_office_attachment_metadata_on_s3_key", unique: true
    t.index ["uploaded_by_id"], name: "index_office_attachment_metadata_on_uploaded_by_id"
  end

  create_table "office_types", force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "office_works", force: :cascade do |t|
    t.bigint "work_id", null: false
    t.bigint "office_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_office_works_on_deleted_at"
    t.index ["office_id"], name: "index_office_works_on_office_id"
    t.index ["work_id"], name: "index_office_works_on_work_id"
  end

  create_table "offices", force: :cascade do |t|
    t.string "name"
    t.string "cnpj"
    t.string "oab_id"
    t.string "society"
    t.date "foundation"
    t.string "site"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "accounting_type"
    t.datetime "deleted_at"
    t.bigint "team_id", null: false
    t.string "oab_status"
    t.string "oab_inscricao"
    t.string "oab_link"
    t.bigint "created_by_id"
    t.bigint "deleted_by_id"
    t.decimal "quote_value", precision: 10, scale: 2, comment: "Value per quote in BRL"
    t.integer "number_of_quotes", default: 0, comment: "Total number of quotes"
    t.string "logo_s3_key"
    t.index ["accounting_type"], name: "index_offices_on_accounting_type"
    t.index ["created_by_id"], name: "index_offices_on_created_by_id"
    t.index ["deleted_at"], name: "index_offices_on_deleted_at"
    t.index ["deleted_by_id"], name: "index_offices_on_deleted_by_id"
    t.index ["logo_s3_key"], name: "index_offices_on_logo_s3_key"
    t.index ["team_id"], name: "index_offices_on_team_id"
  end

  create_table "pending_documents", force: :cascade do |t|
    t.string "description"
    t.bigint "work_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "profile_customer_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_pending_documents_on_deleted_at"
    t.index ["profile_customer_id"], name: "index_pending_documents_on_profile_customer_id"
    t.index ["work_id"], name: "index_pending_documents_on_work_id"
  end

  create_table "phones", force: :cascade do |t|
    t.string "phone_number"
    t.string "phoneable_type"
    t.bigint "phoneable_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_phones_on_deleted_at"
    t.index ["phoneable_type", "phoneable_id"], name: "index_phones_on_phoneable"
  end

  create_table "power_works", force: :cascade do |t|
    t.bigint "power_id", null: false
    t.bigint "work_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_power_works_on_deleted_at"
    t.index ["power_id"], name: "index_power_works_on_power_id"
    t.index ["work_id"], name: "index_power_works_on_work_id"
  end

  create_table "powers", force: :cascade do |t|
    t.string "description", null: false
    t.integer "category", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_base", default: false, null: false
    t.bigint "created_by_team_id"
    t.bigint "law_area_id"
    t.index ["category", "law_area_id"], name: "index_powers_on_category_and_law_area_id"
    t.index ["created_by_team_id"], name: "index_powers_on_created_by_team_id"
    t.index ["is_base"], name: "index_powers_on_is_base"
    t.index ["law_area_id"], name: "index_powers_on_law_area_id"
  end

  create_table "procedural_parties", force: :cascade do |t|
    t.bigint "procedure_id", null: false
    t.string "party_type", null: false
    t.string "partyable_type"
    t.bigint "partyable_id"
    t.string "name"
    t.string "cpf_cnpj"
    t.string "oab_number"
    t.boolean "is_primary", default: false
    t.integer "position"
    t.string "represented_by"
    t.text "notes"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cpf_cnpj"], name: "index_procedural_parties_on_cpf_cnpj"
    t.index ["deleted_at"], name: "index_procedural_parties_on_deleted_at"
    t.index ["party_type"], name: "index_procedural_parties_on_party_type"
    t.index ["partyable_type", "partyable_id"], name: "index_procedural_parties_on_partyable"
    t.index ["partyable_type", "partyable_id"], name: "index_procedural_parties_on_partyable_type_and_partyable_id"
    t.index ["procedure_id", "party_type"], name: "index_procedural_parties_on_procedure_id_and_party_type"
    t.index ["procedure_id"], name: "index_procedural_parties_on_procedure_id"
  end

  create_table "procedures", force: :cascade do |t|
    t.bigint "work_id", null: false
    t.bigint "law_area_id"
    t.string "ancestry"
    t.string "procedure_type", null: false
    t.string "number"
    t.string "city"
    t.string "state"
    t.string "system"
    t.string "competence"
    t.date "start_date"
    t.date "end_date"
    t.string "procedure_class"
    t.string "responsible"
    t.decimal "claim_value", precision: 15, scale: 2
    t.decimal "conviction_value", precision: 15, scale: 2
    t.decimal "received_value", precision: 15, scale: 2
    t.string "status", default: "in_progress"
    t.boolean "justice_free", default: false
    t.boolean "conciliation", default: false
    t.boolean "priority", default: false
    t.string "priority_type"
    t.text "notes"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ancestry"], name: "index_procedures_on_ancestry"
    t.index ["competence"], name: "index_procedures_on_competence"
    t.index ["deleted_at"], name: "index_procedures_on_deleted_at"
    t.index ["law_area_id"], name: "index_procedures_on_law_area_id"
    t.index ["number"], name: "index_procedures_on_number"
    t.index ["procedure_type"], name: "index_procedures_on_procedure_type"
    t.index ["status"], name: "index_procedures_on_status"
    t.index ["system"], name: "index_procedures_on_system"
    t.index ["work_id", "procedure_type"], name: "index_procedures_on_work_id_and_procedure_type"
    t.index ["work_id"], name: "index_procedures_on_work_id"
  end

  create_table "profile_customers", force: :cascade do |t|
    t.string "customer_type"
    t.string "name"
    t.string "last_name"
    t.string "gender"
    t.string "rg"
    t.string "cpf"
    t.string "cnpj"
    t.string "nationality"
    t.string "civil_status"
    t.string "capacity"
    t.string "profession"
    t.string "company"
    t.date "birth"
    t.string "mother_name"
    t.string "number_benefit"
    t.json "document"
    t.string "nit"
    t.string "inss_password"
    t.bigint "customer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "accountant_id"
    t.datetime "deleted_at"
    t.bigint "created_by_id"
    t.string "status", default: "active", null: false
    t.datetime "deceased_at"
    t.index ["accountant_id"], name: "index_profile_customers_on_accountant_id"
    t.index ["created_by_id"], name: "index_profile_customers_on_created_by_id"
    t.index ["customer_id"], name: "index_profile_customers_on_customer_id"
    t.index ["deceased_at"], name: "index_profile_customers_on_deceased_at"
    t.index ["deleted_at"], name: "index_profile_customers_on_deleted_at"
  end

  create_table "recommendations", force: :cascade do |t|
    t.decimal "percentage"
    t.decimal "commission"
    t.bigint "profile_customer_id", null: false
    t.bigint "work_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_recommendations_on_deleted_at"
    t.index ["profile_customer_id"], name: "index_recommendations_on_profile_customer_id"
    t.index ["work_id"], name: "index_recommendations_on_work_id"
  end

  create_table "represents", force: :cascade do |t|
    t.bigint "profile_customer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "representor_id"
    t.string "relationship_type", default: "representation"
    t.boolean "active", default: true, null: false
    t.date "start_date"
    t.date "end_date"
    t.text "notes"
    t.bigint "team_id"
    t.index ["active"], name: "index_represents_on_active"
    t.index ["profile_customer_id", "active"], name: "index_represents_on_profile_customer_id_and_active"
    t.index ["profile_customer_id"], name: "index_represents_on_profile_customer_id"
    t.index ["relationship_type"], name: "index_represents_on_relationship_type"
    t.index ["representor_id", "active"], name: "index_represents_on_representor_id_and_active"
    t.index ["representor_id"], name: "index_represents_on_representor_id"
    t.index ["team_id"], name: "index_represents_on_team_id"
  end

  create_table "team_customers", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "customer_id", null: false
    t.string "customer_email", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_team_customers_on_customer_id"
    t.index ["deleted_at"], name: "index_team_customers_on_deleted_at"
    t.index ["team_id", "customer_email"], name: "index_team_customers_on_team_id_and_customer_email", unique: true
    t.index ["team_id", "customer_id"], name: "index_team_customers_on_team_and_customer", unique: true
    t.index ["team_id", "customer_id"], name: "index_team_customers_on_team_id_and_customer_id", unique: true
    t.index ["team_id"], name: "index_team_customers_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", null: false
    t.string "subdomain", null: false
    t.jsonb "settings", default: {}
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_teams_on_deleted_at"
    t.index ["subdomain"], name: "index_teams_on_subdomain", unique: true
  end

  create_table "user_bank_accounts", force: :cascade do |t|
    t.bigint "bank_account_id", null: false
    t.bigint "user_profile_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["bank_account_id"], name: "index_user_bank_accounts_on_bank_account_id"
    t.index ["deleted_at"], name: "index_user_bank_accounts_on_deleted_at"
    t.index ["user_profile_id"], name: "index_user_bank_accounts_on_user_profile_id"
  end

  create_table "user_emails", force: :cascade do |t|
    t.bigint "email_id", null: false
    t.bigint "user_profile_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_user_emails_on_deleted_at"
    t.index ["email_id"], name: "index_user_emails_on_email_id"
    t.index ["user_profile_id"], name: "index_user_emails_on_user_profile_id"
  end

  create_table "user_offices", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "office_id", null: false
    t.string "partnership_type", null: false
    t.decimal "partnership_percentage", precision: 5, scale: 2, default: "0.0"
    t.boolean "is_administrator", default: false, null: false
    t.string "cna_link"
    t.date "entry_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["office_id"], name: "index_user_offices_on_office_id"
    t.index ["user_id", "office_id"], name: "index_user_offices_on_user_id_and_office_id", unique: true
    t.index ["user_id"], name: "index_user_offices_on_user_id"
  end

  create_table "user_profile_works", force: :cascade do |t|
    t.bigint "user_profile_id", null: false
    t.bigint "work_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_user_profile_works_on_deleted_at"
    t.index ["user_profile_id"], name: "index_user_profile_works_on_user_profile_id"
    t.index ["work_id"], name: "index_user_profile_works_on_work_id"
  end

  create_table "user_profiles", force: :cascade do |t|
    t.string "role"
    t.string "name"
    t.string "last_name"
    t.string "gender"
    t.string "oab"
    t.string "rg"
    t.string "cpf"
    t.string "nationality"
    t.string "civil_status"
    t.date "birth"
    t.string "mother_name"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "office_id"
    t.string "origin"
    t.datetime "deleted_at"
    t.string "avatar_s3_key"
    t.index ["avatar_s3_key"], name: "index_user_profiles_on_avatar_s3_key"
    t.index ["deleted_at"], name: "index_user_profiles_on_deleted_at"
    t.index ["office_id"], name: "index_user_profiles_on_office_id"
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
  end

  create_table "user_society_compensations", force: :cascade do |t|
    t.bigint "user_office_id", null: false
    t.string "compensation_type", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.date "effective_date", null: false
    t.date "end_date"
    t.string "payment_frequency", default: "monthly", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_office_id"], name: "index_user_society_compensations_on_user_office_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jwt_token"
    t.datetime "deleted_at"
    t.string "status", default: "active", null: false
    t.string "oab"
    t.bigint "team_id", null: false
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jwt_token"], name: "index_users_on_jwt_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["team_id"], name: "index_users_on_team_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "whodunnit"
    t.datetime "created_at"
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.string "event", null: false
    t.text "object"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "work_events", force: :cascade do |t|
    t.string "description"
    t.datetime "date"
    t.bigint "work_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_work_events_on_deleted_at"
    t.index ["work_id"], name: "index_work_events_on_work_id"
  end

  create_table "works", force: :cascade do |t|
    t.integer "number"
    t.string "rate_parceled_exfield"
    t.string "folder"
    t.string "note"
    t.string "extra_pending_document"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "other_description", comment: "Descrição do outro tipo de assunto"
    t.boolean "compensations_five_years", comment: "Compensações realizadas nos últimos 5 anos"
    t.boolean "compensations_service", comment: "Compensações de oficio"
    t.boolean "lawsuit", comment: "Possui ação Judicial"
    t.string "gain_projection", comment: "Projeção de ganho"
    t.integer "physical_lawyer"
    t.integer "responsible_lawyer"
    t.integer "partner_lawyer"
    t.integer "intern"
    t.integer "bachelor"
    t.integer "initial_atendee"
    t.bigint "created_by_id"
    t.datetime "deleted_at"
    t.bigint "team_id", null: false
    t.bigint "law_area_id"
    t.string "work_status", default: "active"
    t.index ["created_by_id"], name: "index_works_on_created_by_id"
    t.index ["deleted_at"], name: "index_works_on_deleted_at"
    t.index ["law_area_id"], name: "index_works_on_law_area_id"
    t.index ["team_id"], name: "index_works_on_team_id"
    t.index ["work_status"], name: "index_works_on_work_status"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "compliance_notifications", "teams"
  add_foreign_key "compliance_notifications", "users"
  add_foreign_key "customer_bank_accounts", "bank_accounts"
  add_foreign_key "customer_bank_accounts", "profile_customers"
  add_foreign_key "customer_emails", "emails"
  add_foreign_key "customer_emails", "profile_customers"
  add_foreign_key "customer_files", "profile_customers"
  add_foreign_key "customer_works", "profile_customers"
  add_foreign_key "customer_works", "works"
  add_foreign_key "customers", "users", column: "created_by_id"
  add_foreign_key "documents", "profile_customers"
  add_foreign_key "documents", "works"
  add_foreign_key "draft_works", "works"
  add_foreign_key "drafts", "customers"
  add_foreign_key "drafts", "teams"
  add_foreign_key "drafts", "users"
  add_foreign_key "honoraries", "procedures"
  add_foreign_key "honoraries", "works"
  add_foreign_key "honorary_components", "honoraries"
  add_foreign_key "job_comments", "jobs"
  add_foreign_key "job_comments", "user_profiles"
  add_foreign_key "job_user_profiles", "jobs"
  add_foreign_key "job_user_profiles", "user_profiles"
  add_foreign_key "job_works", "jobs"
  add_foreign_key "job_works", "profile_customers"
  add_foreign_key "job_works", "user_profiles"
  add_foreign_key "job_works", "works"
  add_foreign_key "jobs", "teams"
  add_foreign_key "jobs", "users", column: "created_by_id"
  add_foreign_key "law_areas", "law_areas", column: "parent_area_id"
  add_foreign_key "law_areas", "teams", column: "created_by_team_id"
  add_foreign_key "legal_cost_entries", "legal_cost_types"
  add_foreign_key "legal_cost_entries", "legal_costs"
  add_foreign_key "legal_cost_types", "teams"
  add_foreign_key "legal_costs", "honoraries"
  add_foreign_key "notifications", "teams"
  add_foreign_key "notifications", "user_profiles"
  add_foreign_key "office_attachment_metadata", "offices"
  add_foreign_key "office_attachment_metadata", "users", column: "uploaded_by_id"
  add_foreign_key "office_works", "offices"
  add_foreign_key "office_works", "works"
  add_foreign_key "offices", "teams"
  add_foreign_key "offices", "users", column: "created_by_id"
  add_foreign_key "offices", "users", column: "deleted_by_id"
  add_foreign_key "pending_documents", "profile_customers"
  add_foreign_key "pending_documents", "works"
  add_foreign_key "power_works", "powers"
  add_foreign_key "power_works", "works"
  add_foreign_key "powers", "law_areas"
  add_foreign_key "powers", "teams", column: "created_by_team_id"
  add_foreign_key "procedural_parties", "procedures"
  add_foreign_key "procedures", "law_areas"
  add_foreign_key "procedures", "works"
  add_foreign_key "profile_customers", "customers"
  add_foreign_key "profile_customers", "users", column: "created_by_id"
  add_foreign_key "recommendations", "profile_customers"
  add_foreign_key "recommendations", "works"
  add_foreign_key "represents", "profile_customers"
  add_foreign_key "represents", "profile_customers", column: "representor_id"
  add_foreign_key "represents", "teams"
  add_foreign_key "team_customers", "customers"
  add_foreign_key "team_customers", "teams"
  add_foreign_key "user_bank_accounts", "bank_accounts"
  add_foreign_key "user_bank_accounts", "user_profiles"
  add_foreign_key "user_emails", "emails"
  add_foreign_key "user_emails", "user_profiles"
  add_foreign_key "user_offices", "offices"
  add_foreign_key "user_offices", "users"
  add_foreign_key "user_profile_works", "user_profiles"
  add_foreign_key "user_profile_works", "works"
  add_foreign_key "user_profiles", "offices"
  add_foreign_key "user_profiles", "users"
  add_foreign_key "user_society_compensations", "user_offices"
  add_foreign_key "users", "teams"
  add_foreign_key "work_events", "works"
  add_foreign_key "works", "law_areas"
  add_foreign_key "works", "teams"
  add_foreign_key "works", "users", column: "created_by_id"
end
