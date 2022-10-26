class WalletTransaction < ApplicationRecord
  belongs_to :wallet

  validates :action_type,
            presence: true,
            inclusion: {
              in: %w[deposit withdrawal]
            }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }

  default_scope { order(created_at: :desc) }
end
