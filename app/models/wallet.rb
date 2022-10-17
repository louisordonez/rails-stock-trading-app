class Wallet < ApplicationRecord
  belongs_to :user
  has_many :wallet_transactions

  validates :balance, presence: true, 
              numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_default

  private

  def set_default
    self.balance = 0 if self.balance.nil?
  end
end
