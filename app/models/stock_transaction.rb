class StockTransaction < ApplicationRecord
  belongs_to :user
  belongs_to :portfolio

  validates :action_type, presence: true, inclusion: { in: %w[buy sell] }
  validates :stock_symbol, presence: true
  validates :stock_name, presence: true
  validates :stock_quantity, presence: true, numericality: { greater_than: 0 }
  validates :stock_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  default_scope { order(created_at: :desc) }
end
