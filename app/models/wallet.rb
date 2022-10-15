class Wallet < ApplicationRecord
  belongs_to :user
  has_many :wallet_transactions
end
