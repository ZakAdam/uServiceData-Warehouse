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

ActiveRecord::Schema.define(version: 2021_12_30_170954) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "carriers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "city"
    t.string "zipcode"
    t.string "address"
    t.datetime "created_at", precision: 6, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "now()" }, null: false
  end

  create_table "dates", force: :cascade do |t|
    t.date "delivery_date"
    t.date "invoice_date"
    t.datetime "created_at", precision: 6, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "now()" }, null: false
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "customer_id"
    t.bigint "date_id"
    t.bigint "carrier_id"
    t.bigint "country_id"
    t.decimal "price"
    t.decimal "fees"
    t.decimal "cash_on_delivery"
    t.datetime "created_at", precision: 6, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "now()" }, null: false
    t.index ["carrier_id"], name: "index_invoices_on_carrier_id"
    t.index ["country_id"], name: "index_invoices_on_country_id"
    t.index ["customer_id"], name: "index_invoices_on_customer_id"
    t.index ["date_id"], name: "index_invoices_on_date_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.decimal "price"
    t.integer "rating"
    t.string "ean"
    t.string "product_number"
    t.bigint "order_id"
    t.bigint "review_id"
    t.datetime "created_at", precision: 6, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "now()" }, null: false
    t.index ["review_id"], name: "index_products_on_review_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "rating"
    t.text "summary"
    t.datetime "converted_timestamp"
    t.bigint "original_id"
    t.string "unix_timestamp"
    t.datetime "created_at", precision: 6, default: -> { "now()" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "now()" }, null: false
  end

  add_foreign_key "invoices", "carriers"
  add_foreign_key "invoices", "countries"
  add_foreign_key "invoices", "customers"
  add_foreign_key "invoices", "dates"
  add_foreign_key "products", "reviews"
end
