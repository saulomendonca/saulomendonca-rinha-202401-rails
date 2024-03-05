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

ActiveRecord::Schema[7.1].define(version: 2024_03_01_012808) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.integer "account_limit"
    t.integer "account_balance", default: 0
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "amount"
    t.string "transaction_type"
    t.string "description"
    t.datetime "transaction_date", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.bigint "client_id", null: false
    t.index ["client_id"], name: "index_transactions_on_client_id"
  end

  add_foreign_key "transactions", "clients"
end
