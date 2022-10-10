class CreateUserTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :user_transactions do |t|
      t.string :transaction_type
      t.decimal :stock_quantity
      t.decimal :stock_price
      t.decimal :total_amount

      t.timestamps
    end
  end
end
