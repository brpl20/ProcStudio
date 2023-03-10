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

ActiveRecord::Schema[7.0].define(version: 2023_03_09_195127) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.index ["address_id"], name: "index_admin_addresses_on_address_id"
    t.index ["profile_admin_id"], name: "index_admin_addresses_on_profile_admin_id"
  end

  create_table "admin_bank_accounts", force: :cascade do |t|
    t.bigint "bank_account_id", null: false
    t.bigint "profile_admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_account_id"], name: "index_admin_bank_accounts_on_bank_account_id"
    t.index ["profile_admin_id"], name: "index_admin_bank_accounts_on_profile_admin_id"
  end

  create_table "admin_emails", force: :cascade do |t|
    t.bigint "email_id", null: false
    t.bigint "profile_admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_id"], name: "index_admin_emails_on_email_id"
    t.index ["profile_admin_id"], name: "index_admin_emails_on_profile_admin_id"
  end

  create_table "admin_phones", force: :cascade do |t|
    t.bigint "phone_id", null: false
    t.bigint "profile_admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["email"], name: "index_admins_on_email", unique: true
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
  end

  create_table "checklist_documents", force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "client_addresses", force: :cascade do |t|
    t.bigint "profile_customer_id", null: false
    t.bigint "addresses_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addresses_id"], name: "index_client_addresses_on_addresses_id"
    t.index ["profile_customer_id"], name: "index_client_addresses_on_profile_customer_id"
  end

  create_table "customer_bank_accounts", force: :cascade do |t|
    t.bigint "profile_customer_id", null: false
    t.bigint "bank_accounts_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_accounts_id"], name: "index_customer_bank_accounts_on_bank_accounts_id"
    t.index ["profile_customer_id"], name: "index_customer_bank_accounts_on_profile_customer_id"
  end

  create_table "customer_emails", force: :cascade do |t|
    t.bigint "profile_customer_id", null: false
    t.bigint "emails_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["emails_id"], name: "index_customer_emails_on_emails_id"
    t.index ["profile_customer_id"], name: "index_customer_emails_on_profile_customer_id"
  end

  create_table "customer_phones", force: :cascade do |t|
    t.bigint "profile_customer_id", null: false
    t.bigint "phones_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phones_id"], name: "index_customer_phones_on_phones_id"
    t.index ["profile_customer_id"], name: "index_customer_phones_on_profile_customer_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_customers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_customers_on_reset_password_token", unique: true
  end

  create_table "emails", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "office_bank_accounts", force: :cascade do |t|
    t.bigint "bank_account_id", null: false
    t.bigint "office_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_account_id"], name: "index_office_bank_accounts_on_bank_account_id"
    t.index ["office_id"], name: "index_office_bank_accounts_on_office_id"
  end

  create_table "office_emails", force: :cascade do |t|
    t.bigint "office_id", null: false
    t.bigint "email_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_id"], name: "index_office_emails_on_email_id"
    t.index ["office_id"], name: "index_office_emails_on_office_id"
  end

  create_table "office_phones", force: :cascade do |t|
    t.bigint "office_id", null: false
    t.bigint "phone_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["office_id"], name: "index_office_phones_on_office_id"
    t.index ["phone_id"], name: "index_office_phones_on_phone_id"
  end

  create_table "office_types", force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "offices", force: :cascade do |t|
    t.string "name"
    t.string "cnpj"
    t.string "oab"
    t.integer "society"
    t.date "foundation"
    t.string "site"
    t.string "cep"
    t.string "street"
    t.integer "number"
    t.string "neighborhood"
    t.string "city"
    t.string "state"
    t.bigint "office_type_id", null: false
    t.bigint "profile_admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["office_type_id"], name: "index_offices_on_office_type_id"
    t.index ["profile_admin_id"], name: "index_offices_on_profile_admin_id"
  end

  create_table "phones", force: :cascade do |t|
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "powers", force: :cascade do |t|
    t.string "description"
    t.integer "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profile_admins", force: :cascade do |t|
    t.integer "role"
    t.string "name"
    t.string "lastname"
    t.integer "gender"
    t.string "oab"
    t.string "rg"
    t.string "cpf"
    t.string "nationality"
    t.integer "civil_status"
    t.date "birth"
    t.string "mother_name"
    t.integer "status"
    t.bigint "admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_profile_admins_on_admin_id"
  end

  create_table "profile_customers", force: :cascade do |t|
    t.integer "type"
    t.string "name"
    t.string "lastname"
    t.integer "gender"
    t.string "rg"
    t.string "cpf"
    t.string "cnpj"
    t.string "nationality"
    t.integer "civil_status"
    t.integer "capacity"
    t.string "profession"
    t.string "company"
    t.date "birth"
    t.string "monther_name"
    t.string "number_benefit"
    t.integer "status"
    t.json "document"
    t.string "nit"
    t.string "inss_password"
    t.integer "invalid_person"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "works", force: :cascade do |t|
    t.string "procedure"
    t.string "subject"
    t.string "action"
    t.integer "number"
    t.string "rate_percentage"
    t.string "rate_percentage_exfield"
    t.string "rate_fixed"
    t.string "rate_parceled_exfield"
    t.string "folder"
    t.string "initial_atendee"
    t.string "note"
    t.string "checklist"
    t.string "pending_document"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "admin_addresses", "addresses"
  add_foreign_key "admin_addresses", "profile_admins"
  add_foreign_key "admin_bank_accounts", "bank_accounts"
  add_foreign_key "admin_bank_accounts", "profile_admins"
  add_foreign_key "admin_emails", "emails"
  add_foreign_key "admin_emails", "profile_admins"
  add_foreign_key "admin_phones", "phones"
  add_foreign_key "admin_phones", "profile_admins"
  add_foreign_key "client_addresses", "addresses", column: "addresses_id"
  add_foreign_key "client_addresses", "profile_customers"
  add_foreign_key "customer_bank_accounts", "bank_accounts", column: "bank_accounts_id"
  add_foreign_key "customer_bank_accounts", "profile_customers"
  add_foreign_key "customer_emails", "emails", column: "emails_id"
  add_foreign_key "customer_emails", "profile_customers"
  add_foreign_key "customer_phones", "phones", column: "phones_id"
  add_foreign_key "customer_phones", "profile_customers"
  add_foreign_key "office_bank_accounts", "bank_accounts"
  add_foreign_key "office_bank_accounts", "offices"
  add_foreign_key "office_emails", "emails"
  add_foreign_key "office_emails", "offices"
  add_foreign_key "office_phones", "offices"
  add_foreign_key "office_phones", "phones"
  add_foreign_key "offices", "office_types"
  add_foreign_key "offices", "profile_admins"
  add_foreign_key "profile_admins", "admins"
end
