class CreateWalletTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :wallet_transactions do |t|
      t.string :action_type
      t.decimal :total_amount
      t.references :user, null: false, foreign_key: true
      t.references :wallet, null: false, foreign_key: true

      t.timestamps
    end
  end
end
