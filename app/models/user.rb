class User < ApplicationRecord
  has_secure_password

  has_and_belongs_to_many :roles
  has_many :stock_transactions
  has_many :portfolios, through: :stock_transactions
  has_one :wallet
  has_many :wallet_transactions, through: :wallet

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :email_verified, inclusion: [true, false]
  validates :trade_verified, inclusion: [true, false]

  before_validation :set_default

  private

  def set_default
    self.email_verified = false if self.email_verified.nil?
    self.trade_verified = false if self.trade_verified.nil?
  end
end
