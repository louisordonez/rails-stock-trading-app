class CreateStockTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_transactions do |t|
      t.string :action_type
      t.string :stock_symbol
      t.string :stock_name
      t.decimal :stock_quantity
      t.decimal :stock_price
      t.decimal :total_amount
      t.references :user, null: false, foreign_key: true
      t.references :portfolio, null: false, foreign_key: true

      t.timestamps
    end
  end
end
