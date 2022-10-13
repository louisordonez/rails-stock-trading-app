class User < ApplicationRecord
  has_secure_password

  has_and_belongs_to_many :roles
  has_many :stock_transactions
  has_many :portfolios, through: :stock_transactions
  has_many :wallet_transactions
  has_many :wallets, through: :wallet_transactions

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password_digest, presence: true
end
