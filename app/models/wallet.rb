class Wallet < ApplicationRecord
  has_many :wallet_transactions
  has_many :users, through: :wallet_transactions
end
