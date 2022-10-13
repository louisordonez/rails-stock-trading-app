class User < ApplicationRecord
  has_secure_password

  has_and_belongs_to_many :roles
  has_many :stock_transactions
  has_many :portfolios, through: :stock_transactions
end
