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

ActiveRecord::Schema[8.0].define(version: 2025_07_23_151117) do
  create_table "accounts", force: :cascade do |t|
    t.integer "subscription_id", null: false
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.date "due_date", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_id", "item_type", "item_id", "due_date"], name: "idx_accounts_unique_item"
    t.index ["subscription_id"], name: "index_accounts_on_subscription_id"
  end

  create_table "additional_services", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "price", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_additional_services_on_name"
  end

  create_table "booklet_invoices", force: :cascade do |t|
    t.integer "booklet_id", null: false
    t.integer "invoice_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booklet_id", "invoice_id"], name: "index_booklet_invoices_on_booklet_id_and_invoice_id", unique: true
    t.index ["booklet_id"], name: "index_booklet_invoices_on_booklet_id"
    t.index ["invoice_id"], name: "index_booklet_invoices_on_invoice_id"
  end

  create_table "booklets", force: :cascade do |t|
    t.integer "subscription_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_id"], name: "index_booklets_on_subscription_id", unique: true
  end

  create_table "clients", force: :cascade do |t|
    t.string "name", null: false
    t.integer "age", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_clients_on_name"
  end

  create_table "invoice_accounts", force: :cascade do |t|
    t.integer "invoice_id", null: false
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_invoice_accounts_on_account_id"
    t.index ["invoice_id", "account_id"], name: "index_invoice_accounts_on_invoice_id_and_account_id", unique: true
    t.index ["invoice_id"], name: "index_invoice_accounts_on_invoice_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "subscription_id", null: false
    t.date "due_date", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_id", "due_date"], name: "index_invoices_on_subscription_id_and_due_date", unique: true
    t.index ["subscription_id"], name: "index_invoices_on_subscription_id"
  end

  create_table "packages", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "price", null: false
    t.integer "plan_id", null: false
    t.integer "additional_service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["additional_service_id"], name: "index_packages_on_additional_service_id"
    t.index ["name"], name: "index_packages_on_name"
    t.index ["plan_id"], name: "index_packages_on_plan_id"
  end

  create_table "plans", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "price", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_plans_on_name"
  end

  create_table "subscription_additional_services", force: :cascade do |t|
    t.integer "subscription_id", null: false
    t.integer "additional_service_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes"
    t.index ["additional_service_id"], name: "idx_on_additional_service_id_305e585373"
    t.index ["subscription_id", "additional_service_id"], name: "idx_subscription_additional_services_unique", unique: true
    t.index ["subscription_id"], name: "index_subscription_additional_services_on_subscription_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer "client_id", null: false
    t.integer "plan_id"
    t.integer "package_id"
    t.date "subscription_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes"
    t.date "start_date"
    t.date "end_date"
    t.string "status"
    t.index ["client_id", "subscription_date"], name: "index_subscriptions_on_client_id_and_subscription_date"
    t.index ["client_id"], name: "index_subscriptions_on_client_id"
    t.index ["package_id"], name: "index_subscriptions_on_package_id"
    t.index ["plan_id"], name: "index_subscriptions_on_plan_id"
  end

  add_foreign_key "accounts", "subscriptions"
  add_foreign_key "booklet_invoices", "booklets"
  add_foreign_key "booklet_invoices", "invoices"
  add_foreign_key "booklets", "subscriptions"
  add_foreign_key "invoice_accounts", "accounts"
  add_foreign_key "invoice_accounts", "invoices"
  add_foreign_key "invoices", "subscriptions"
  add_foreign_key "packages", "additional_services"
  add_foreign_key "packages", "plans"
  add_foreign_key "subscription_additional_services", "additional_services"
  add_foreign_key "subscription_additional_services", "subscriptions"
  add_foreign_key "subscriptions", "clients"
  add_foreign_key "subscriptions", "packages"
  add_foreign_key "subscriptions", "plans"
end
