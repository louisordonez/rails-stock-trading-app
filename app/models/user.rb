class User < ApplicationRecord
  require 'securerandom'
  has_secure_password
  has_and_belongs_to_many :roles

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password_digest, presence: true
  # validates :role, presence: true
end
