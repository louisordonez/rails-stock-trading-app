class User < ApplicationRecord
  require 'securerandom'

  has_secure_password

  validate :first_name
  validate :last_name
  validates :email, uniqueness: true
  validate :password
  validate :role
end
