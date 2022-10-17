class Portfolio < ApplicationRecord
  has_many :stock_transactions
  has_many :users, through: :stock_transactions

  validates :stock_name, presence: true
  validates :stock_symbol, presence: true
  validates :stocks_owned_quantity, presence: true,
              numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_default

  private

  def set_default
    self.stocks_owned_quantity = 0 if self.stocks_owned_quantity.nil?
  end
end
