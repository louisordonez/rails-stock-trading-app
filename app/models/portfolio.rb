class Portfolio < ApplicationRecord
  belongs_to :user
  belongs_to :user_transaction
end
