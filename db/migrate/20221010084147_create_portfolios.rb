class CreatePortfolios < ActiveRecord::Migration[7.0]
  def change
    create_table :portfolios do |t|
      t.string :stock_name
      t.string :stock_symbol
      t.decimal :stocks_owned_quantity
      t.references :user, null: false, foreign_key: true
      t.references :user_transaction, null: false, foreign_key: true

      t.timestamps
    end
  end
end
