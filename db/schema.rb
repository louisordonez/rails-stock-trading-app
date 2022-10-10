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

ActiveRecord::Schema[7.0].define(version: 2022_10_10_084147) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "portfolios", force: :cascade do |t|
    t.string "stock_name"
    t.string "stock_symbol"
    t.decimal "stocks_owned_quantity"
    t.bigint "user_id", null: false
    t.bigint "user_transaction_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_portfolios_on_user_id"
    t.index ["user_transaction_id"], name: "index_portfolios_on_user_transaction_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
  end

  create_table "user_transactions", force: :cascade do |t|
    t.string "transaction_type"
    t.decimal "stock_quantity"
    t.decimal "stock_price"
    t.decimal "total_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "password_digest"
    t.boolean "email_verified", default: false
    t.boolean "trade_verified", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "balance"
  end

  add_foreign_key "portfolios", "user_transactions"
  add_foreign_key "portfolios", "users"
end
