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

ActiveRecord::Schema[7.0].define(version: 2025_08_04_020443) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.string "description"
    t.string "zip_code"
    t.string "street"
    t.integer "number"
    t.string "neighborhood"
    t.string "city"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_addresses", force: :cascade do |t|
    t.bigint "address_id", null: false
    t.bigint "profile_admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["address_id"], name: "index_admin_addresses_on_address_id"
    t.index ["deleted_at"], name: "index_admin_addresses_on_deleted_at"
    t.index ["profile_admin_id"], name: "index_admin_addresses_on_profile_admin_id"
  end

  create_table "admin_bank_accounts", force: :cascade do |t|
    t.bigint "bank_account_id", null: false
    t.bigint "profile_admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["bank_account_id"], name: "index_admin_bank_accounts_on_bank_account_id"
    t.index ["deleted_at"], name: "index_admin_bank_accounts_on_deleted_at"
    t.index ["profile_admin_id"], name: "index_admin_bank_accounts_on_profile_admin_id"
  end

  create_table "admin_emails", force: :cascade do |t|
    t.bigint "email_id", null: false
    t.bigint "profile_admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_admin_emails_on_deleted_at"
    t.index ["email_id"], name: "index_admin_emails_on_email_id"
    t.index ["profile_admin_id"], name: "index_admin_emails_on_profile_admin_id"
  end

  create_table "admin_phones", force: :cascade do |t|
    t.bigint "phone_id", null: false
    t.bigint "profile_admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_admin_phones_on_deleted_at"
    t.index ["phone_id"], name: "index_admin_phones_on_phone_id"
    t.index ["profile_admin_id"], name: "index_admin_phones_on_profile_admin_id"
  end

  create_table "admins", force: :cascade do |t|
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
    t.index ["deleted_at"], name: "index_admins_on_deleted_at"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["jwt_token"], name: "index_admins_on_jwt_token", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.string "bank_name"
    t.string "type_account"
    t.string "agency"
    t.string "account"
    t.string "operation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pix"
  end

  create_table "contact_infos", force: :cascade do |t|
    t.string "contactable_type", null: false
    t.bigint "contactable_id", null: false
    t.string "contact_type", null: false
    t.json "contact_data", default: {}, null: false
    t.boolean "is_primary", default: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_type", "contactable_type", "contactable_id"], name: "index_contact_infos_on_type_and_contactable"
    t.index ["contactable_type", "contactable_id", "is_primary"], name: "index_contact_infos_on_primary"
    t.index ["contactable_type", "contactable_id"], name: "index_contact_infos_on_contactable"
    t.index ["contactable_type", "contactable_id"], name: "index_contact_infos_on_contactable_type_and_contactable_id"
    t.index ["deleted_at"], name: "index_contact_infos_on_deleted_at"
  end

  create_table "customer_addresses", force: :cascade do |t|
    t.bigint "profile_customer_id", null: false
    t.bigint "address_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["address_id"], name: "index_customer_addresses_on_address_id"
    t.index ["deleted_at"], name: "index_customer_addresses_on_deleted_at"
    t.index ["profile_customer_id"], name: "index_customer_addresses_on_profile_customer_id"
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
    t.index ["deleted_at"], name: "index_customer_files_on_deleted_at"
    t.index ["profile_customer_id"], name: "index_customer_files_on_profile_customer_id"
  end

  create_table "customer_phones", force: :cascade do |t|
    t.bigint "profile_customer_id", null: false
    t.bigint "phone_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_customer_phones_on_deleted_at"
    t.index ["phone_id"], name: "index_customer_phones_on_phone_id"
    t.index ["profile_customer_id"], name: "index_customer_phones_on_profile_customer_id"
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
    t.index ["email"], name: "index_customers_on_email_where_not_deleted", unique: true, where: "(deleted_at IS NULL)"
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

  create_table "emails", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "honoraries", force: :cascade do |t|
    t.string "fixed_honorary_value"
    t.string "parcelling_value"
    t.string "honorary_type"
    t.string "percent_honorary_value"
    t.boolean "parcelling"
    t.bigint "work_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "work_prev"
    t.index ["deleted_at"], name: "index_honoraries_on_deleted_at"
    t.index ["work_id"], name: "index_honoraries_on_work_id"
  end

  create_table "individual_entities", force: :cascade do |t|
    t.string "name", null: false
    t.string "last_name"
    t.string "gender"
    t.string "rg"
    t.string "cpf", null: false
    t.string "nationality"
    t.string "civil_status"
    t.string "profession"
    t.date "birth"
    t.string "mother_name"
    t.string "nit"
    t.string "inss_password"
    t.boolean "invalid_person", default: false
    t.json "additional_documents", default: {}
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cpf"], name: "index_individual_entities_on_cpf", unique: true
    t.index ["deleted_at"], name: "index_individual_entities_on_deleted_at"
    t.index ["name", "last_name"], name: "index_individual_entities_on_name_and_last_name"
  end

  create_table "job_works", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "work_id", null: false
    t.bigint "profile_admin_id", null: false
    t.bigint "profile_customer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_job_works_on_job_id"
    t.index ["profile_admin_id"], name: "index_job_works_on_profile_admin_id"
    t.index ["profile_customer_id"], name: "index_job_works_on_profile_customer_id"
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
    t.bigint "profile_admin_id"
    t.bigint "work_id"
    t.bigint "profile_customer_id"
    t.bigint "created_by_id"
    t.datetime "deleted_at"
    t.index ["created_by_id"], name: "index_jobs_on_created_by_id"
    t.index ["deleted_at"], name: "index_jobs_on_deleted_at"
    t.index ["profile_admin_id"], name: "index_jobs_on_profile_admin_id"
    t.index ["profile_customer_id"], name: "index_jobs_on_profile_customer_id"
    t.index ["work_id"], name: "index_jobs_on_work_id"
  end

  create_table "legal_entities", force: :cascade do |t|
    t.string "name", null: false
    t.string "cnpj"
    t.string "inscription_number"
    t.string "state_registration"
    t.string "oab_id"
    t.string "society_link"
    t.integer "number_of_partners"
    t.string "status", default: "active"
    t.string "accounting_type"
    t.string "entity_type"
    t.bigint "legal_representative_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cnpj"], name: "index_legal_entities_on_cnpj", unique: true, where: "(cnpj IS NOT NULL)"
    t.index ["deleted_at"], name: "index_legal_entities_on_deleted_at"
    t.index ["entity_type"], name: "index_legal_entities_on_entity_type"
    t.index ["legal_representative_id"], name: "index_legal_entities_on_legal_representative_id"
    t.index ["status"], name: "index_legal_entities_on_status"
  end

  create_table "office_bank_accounts", force: :cascade do |t|
    t.bigint "bank_account_id", null: false
    t.bigint "office_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["bank_account_id"], name: "index_office_bank_accounts_on_bank_account_id"
    t.index ["deleted_at"], name: "index_office_bank_accounts_on_deleted_at"
    t.index ["office_id"], name: "index_office_bank_accounts_on_office_id"
  end

  create_table "office_emails", force: :cascade do |t|
    t.bigint "office_id", null: false
    t.bigint "email_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_office_emails_on_deleted_at"
    t.index ["email_id"], name: "index_office_emails_on_email_id"
    t.index ["office_id"], name: "index_office_emails_on_office_id"
  end

  create_table "office_phones", force: :cascade do |t|
    t.bigint "office_id", null: false
    t.bigint "phone_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_office_phones_on_deleted_at"
    t.index ["office_id"], name: "index_office_phones_on_office_id"
    t.index ["phone_id"], name: "index_office_phones_on_phone_id"
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
    t.string "oab"
    t.string "society"
    t.date "foundation"
    t.string "site"
    t.string "cep"
    t.string "street"
    t.integer "number"
    t.string "neighborhood"
    t.string "city"
    t.string "state"
    t.bigint "office_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "responsible_lawyer_id"
    t.string "accounting_type"
    t.datetime "deleted_at"
    t.bigint "team_id"
    t.index ["accounting_type"], name: "index_offices_on_accounting_type"
    t.index ["deleted_at"], name: "index_offices_on_deleted_at"
    t.index ["office_type_id"], name: "index_offices_on_office_type_id"
    t.index ["responsible_lawyer_id"], name: "index_offices_on_responsible_lawyer_id"
    t.index ["team_id"], name: "index_offices_on_team_id"
  end

  create_table "payment_transactions", force: :cascade do |t|
    t.bigint "subscription_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "currency", default: "BRL"
    t.string "status", default: "pending"
    t.string "payment_method"
    t.string "transaction_id"
    t.json "payment_data", default: {}
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["processed_at"], name: "index_payment_transactions_on_processed_at"
    t.index ["status"], name: "index_payment_transactions_on_status"
    t.index ["subscription_id"], name: "index_payment_transactions_on_subscription_id"
    t.index ["transaction_id"], name: "index_payment_transactions_on_transaction_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  end

  create_table "profile_admin_works", force: :cascade do |t|
    t.bigint "profile_admin_id", null: false
    t.bigint "work_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_profile_admin_works_on_deleted_at"
    t.index ["profile_admin_id"], name: "index_profile_admin_works_on_profile_admin_id"
    t.index ["work_id"], name: "index_profile_admin_works_on_work_id"
  end

  create_table "profile_admins", force: :cascade do |t|
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
    t.string "status"
    t.bigint "admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "office_id"
    t.string "origin"
    t.datetime "deleted_at"
    t.bigint "individual_entity_id"
    t.bigint "legal_entity_id"
    t.index ["admin_id"], name: "index_profile_admins_on_admin_id"
    t.index ["deleted_at"], name: "index_profile_admins_on_deleted_at"
    t.index ["individual_entity_id"], name: "index_profile_admins_on_individual_entity_id"
    t.index ["legal_entity_id"], name: "index_profile_admins_on_legal_entity_id"
    t.index ["office_id"], name: "index_profile_admins_on_office_id"
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
    t.integer "invalid_person"
    t.bigint "customer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "accountant_id"
    t.datetime "deleted_at"
    t.bigint "created_by_id"
    t.string "status", default: "active", null: false
    t.bigint "individual_entity_id"
    t.bigint "legal_entity_id"
    t.index ["accountant_id"], name: "index_profile_customers_on_accountant_id"
    t.index ["created_by_id"], name: "index_profile_customers_on_created_by_id"
    t.index ["customer_id"], name: "index_profile_customers_on_customer_id"
    t.index ["deleted_at"], name: "index_profile_customers_on_deleted_at"
    t.index ["individual_entity_id"], name: "index_profile_customers_on_individual_entity_id"
    t.index ["legal_entity_id"], name: "index_profile_customers_on_legal_entity_id"
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
    t.index ["profile_customer_id"], name: "index_represents_on_profile_customer_id"
    t.index ["representor_id"], name: "index_represents_on_representor_id"
  end

  create_table "subscription_plans", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "price", precision: 10, scale: 2
    t.string "currency", default: "BRL"
    t.string "billing_interval"
    t.integer "max_users"
    t.integer "max_offices"
    t.integer "max_cases"
    t.json "features", default: {}
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["billing_interval"], name: "index_subscription_plans_on_billing_interval"
    t.index ["is_active"], name: "index_subscription_plans_on_is_active"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "subscription_plan_id", null: false
    t.date "start_date", null: false
    t.date "end_date"
    t.string "status", default: "trial"
    t.date "trial_end_date"
    t.decimal "monthly_amount", precision: 10, scale: 2
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_subscriptions_on_deleted_at"
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["subscription_plan_id"], name: "index_subscriptions_on_subscription_plan_id"
    t.index ["team_id", "status"], name: "index_subscriptions_on_team_id_and_status"
    t.index ["team_id"], name: "index_subscriptions_on_team_id"
  end

  create_table "team_memberships", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "admin_id", null: false
    t.string "role", default: "member", null: false
    t.string "status", default: "active"
    t.datetime "joined_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_team_memberships_on_admin_id"
    t.index ["deleted_at"], name: "index_team_memberships_on_deleted_at"
    t.index ["role"], name: "index_team_memberships_on_role"
    t.index ["status"], name: "index_team_memberships_on_status"
    t.index ["team_id", "admin_id"], name: "index_team_memberships_on_team_id_and_admin_id", unique: true
    t.index ["team_id"], name: "index_team_memberships_on_team_id"
  end

  create_table "team_offices", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "office_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_team_offices_on_deleted_at"
    t.index ["office_id"], name: "index_team_offices_on_office_id"
    t.index ["team_id", "office_id"], name: "index_team_offices_on_team_id_and_office_id", unique: true
    t.index ["team_id"], name: "index_team_offices_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", null: false
    t.string "subdomain", null: false
    t.bigint "main_admin_id", null: false
    t.bigint "owner_admin_id", null: false
    t.string "status", default: "active"
    t.json "settings", default: {}
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_teams_on_deleted_at"
    t.index ["main_admin_id"], name: "index_teams_on_main_admin_id"
    t.index ["owner_admin_id"], name: "index_teams_on_owner_admin_id"
    t.index ["status"], name: "index_teams_on_status"
    t.index ["subdomain"], name: "index_teams_on_subdomain", unique: true
  end

  create_table "wiki_categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.bigint "team_id", null: false
    t.bigint "parent_id"
    t.integer "position", default: 0
    t.string "color"
    t.string "icon"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_wiki_categories_on_deleted_at"
    t.index ["parent_id"], name: "index_wiki_categories_on_parent_id"
    t.index ["position"], name: "index_wiki_categories_on_position"
    t.index ["team_id", "parent_id"], name: "index_wiki_categories_on_team_id_and_parent_id"
    t.index ["team_id", "slug"], name: "index_wiki_categories_on_team_id_and_slug", unique: true
    t.index ["team_id"], name: "index_wiki_categories_on_team_id"
  end

  create_table "wiki_page_categories", force: :cascade do |t|
    t.bigint "wiki_page_id", null: false
    t.bigint "wiki_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wiki_category_id"], name: "index_wiki_page_categories_on_wiki_category_id"
    t.index ["wiki_page_id", "wiki_category_id"], name: "index_wiki_page_categories_unique", unique: true
    t.index ["wiki_page_id"], name: "index_wiki_page_categories_on_wiki_page_id"
  end

  create_table "wiki_page_revisions", force: :cascade do |t|
    t.bigint "wiki_page_id", null: false
    t.string "title", null: false
    t.text "content"
    t.integer "version_number", null: false
    t.bigint "created_by_id", null: false
    t.text "change_summary"
    t.json "diff_data", default: {}
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_wiki_page_revisions_on_created_by_id"
    t.index ["deleted_at"], name: "index_wiki_page_revisions_on_deleted_at"
    t.index ["wiki_page_id", "version_number"], name: "index_wiki_page_revisions_on_wiki_page_id_and_version_number", unique: true
    t.index ["wiki_page_id"], name: "index_wiki_page_revisions_on_wiki_page_id"
  end

  create_table "wiki_pages", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.text "content"
    t.bigint "team_id", null: false
    t.bigint "created_by_id", null: false
    t.bigint "updated_by_id", null: false
    t.bigint "parent_id"
    t.integer "position", default: 0
    t.boolean "is_published", default: false
    t.boolean "is_locked", default: false
    t.json "metadata", default: {}
    t.datetime "published_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_wiki_pages_on_created_by_id"
    t.index ["deleted_at"], name: "index_wiki_pages_on_deleted_at"
    t.index ["is_published"], name: "index_wiki_pages_on_is_published"
    t.index ["parent_id"], name: "index_wiki_pages_on_parent_id"
    t.index ["position"], name: "index_wiki_pages_on_position"
    t.index ["team_id", "parent_id"], name: "index_wiki_pages_on_team_id_and_parent_id"
    t.index ["team_id", "slug"], name: "index_wiki_pages_on_team_id_and_slug", unique: true
    t.index ["team_id"], name: "index_wiki_pages_on_team_id"
    t.index ["updated_by_id"], name: "index_wiki_pages_on_updated_by_id"
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
    t.string "procedure"
    t.string "subject"
    t.integer "number"
    t.string "rate_parceled_exfield"
    t.string "folder"
    t.string "note"
    t.string "extra_pending_document"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "civel_area", comment: "Civil aréas"
    t.string "social_security_areas", comment: "Previdênciário aréas"
    t.string "laborite_areas", comment: "Trabalhista aréas"
    t.string "tributary_areas", comment: "Tributário aréas"
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
    t.text "procedures", default: [], array: true
    t.bigint "created_by_id"
    t.string "status", default: "in_progress"
    t.datetime "deleted_at"
    t.index ["created_by_id"], name: "index_works_on_created_by_id"
    t.index ["deleted_at"], name: "index_works_on_deleted_at"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "admin_addresses", "addresses"
  add_foreign_key "admin_addresses", "profile_admins"
  add_foreign_key "admin_bank_accounts", "bank_accounts"
  add_foreign_key "admin_bank_accounts", "profile_admins"
  add_foreign_key "admin_emails", "emails"
  add_foreign_key "admin_emails", "profile_admins"
  add_foreign_key "admin_phones", "phones"
  add_foreign_key "admin_phones", "profile_admins"
  add_foreign_key "customer_addresses", "addresses"
  add_foreign_key "customer_addresses", "profile_customers"
  add_foreign_key "customer_bank_accounts", "bank_accounts"
  add_foreign_key "customer_bank_accounts", "profile_customers"
  add_foreign_key "customer_emails", "emails"
  add_foreign_key "customer_emails", "profile_customers"
  add_foreign_key "customer_files", "profile_customers"
  add_foreign_key "customer_phones", "phones"
  add_foreign_key "customer_phones", "profile_customers"
  add_foreign_key "customer_works", "profile_customers"
  add_foreign_key "customer_works", "works"
  add_foreign_key "customers", "admins", column: "created_by_id"
  add_foreign_key "documents", "profile_customers"
  add_foreign_key "documents", "works"
  add_foreign_key "draft_works", "works"
  add_foreign_key "honoraries", "works"
  add_foreign_key "job_works", "jobs"
  add_foreign_key "job_works", "profile_admins"
  add_foreign_key "job_works", "profile_customers"
  add_foreign_key "job_works", "works"
  add_foreign_key "jobs", "admins", column: "created_by_id"
  add_foreign_key "legal_entities", "individual_entities", column: "legal_representative_id"
  add_foreign_key "office_bank_accounts", "bank_accounts"
  add_foreign_key "office_bank_accounts", "offices"
  add_foreign_key "office_emails", "emails"
  add_foreign_key "office_emails", "offices"
  add_foreign_key "office_phones", "offices"
  add_foreign_key "office_phones", "phones"
  add_foreign_key "office_works", "offices"
  add_foreign_key "office_works", "works"
  add_foreign_key "offices", "office_types"
  add_foreign_key "offices", "teams"
  add_foreign_key "payment_transactions", "subscriptions"
  add_foreign_key "pending_documents", "profile_customers"
  add_foreign_key "pending_documents", "works"
  add_foreign_key "power_works", "powers"
  add_foreign_key "power_works", "works"
  add_foreign_key "profile_admin_works", "profile_admins"
  add_foreign_key "profile_admin_works", "works"
  add_foreign_key "profile_admins", "admins"
  add_foreign_key "profile_admins", "individual_entities"
  add_foreign_key "profile_admins", "legal_entities"
  add_foreign_key "profile_admins", "offices"
  add_foreign_key "profile_customers", "admins", column: "created_by_id"
  add_foreign_key "profile_customers", "customers"
  add_foreign_key "profile_customers", "individual_entities"
  add_foreign_key "profile_customers", "legal_entities"
  add_foreign_key "recommendations", "profile_customers"
  add_foreign_key "recommendations", "works"
  add_foreign_key "represents", "profile_customers"
  add_foreign_key "represents", "profile_customers", column: "representor_id"
  add_foreign_key "subscriptions", "subscription_plans"
  add_foreign_key "subscriptions", "teams"
  add_foreign_key "team_memberships", "admins"
  add_foreign_key "team_memberships", "teams"
  add_foreign_key "team_offices", "offices"
  add_foreign_key "team_offices", "teams"
  add_foreign_key "teams", "admins", column: "main_admin_id"
  add_foreign_key "teams", "admins", column: "owner_admin_id"
  add_foreign_key "wiki_categories", "teams"
  add_foreign_key "wiki_categories", "wiki_categories", column: "parent_id"
  add_foreign_key "wiki_page_categories", "wiki_categories"
  add_foreign_key "wiki_page_categories", "wiki_pages"
  add_foreign_key "wiki_page_revisions", "admins", column: "created_by_id"
  add_foreign_key "wiki_page_revisions", "wiki_pages"
  add_foreign_key "wiki_pages", "admins", column: "created_by_id"
  add_foreign_key "wiki_pages", "admins", column: "updated_by_id"
  add_foreign_key "wiki_pages", "teams"
  add_foreign_key "wiki_pages", "wiki_pages", column: "parent_id"
  add_foreign_key "work_events", "works"
  add_foreign_key "works", "admins", column: "created_by_id"
end
