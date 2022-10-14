class Portfolio < ApplicationRecord
  has_many :stock_transactions
  has_many :users, through: :stock_transactions
end
