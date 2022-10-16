class StockTransaction < ApplicationRecord
  belongs_to :user
  belongs_to :portfolio

  validates :action_type, presence: true,
              inclusion: { in: ["buy", "sell"] }
  validates :stock_quantity, presence: true,
              numericality: { greater_than: 0 }
  validates :stock_price, presence: true,
              numericality: { greater_than_or_equal_to: 0 }
  validates :total_amount, presence: true,
              numericality: { greater_than_or_equal_to: 0 }
  
  default_scope { order(created_at: :desc) }
end
