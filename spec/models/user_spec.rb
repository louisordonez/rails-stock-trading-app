require 'rails_helper'

RSpec.describe User, type: :model do
  context 'before user creation' do
    it 'should have a first name' do
      expect {
        User.create!(
          last_name: 'last name',
          email: 'email@email.com',
          password: 'password'
        )
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should have a last name' do
      expect {
        User.create!(
          first_name: 'first name',
          email: 'email@email.com',
          password: 'password'
        )
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should have an email' do
      expect {
        User.create!(
          first_name: 'first name',
          last_name: 'last name',
          password: 'password'
        )
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should have a password' do
      expect {
        User.create!(
          first_name: 'first name',
          last_name: 'last name',
          email: 'email@email.com'
        )
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should have a minimum password length of 6' do
      expect {
        User.create!(
          first_name: 'first name',
          last_name: 'last name',
          email: 'email@email.com',
          password: '12345'
        )
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context 'upon user creation' do
    it 'should not have a verified email' do
      user =
        User.create!(
          first_name: 'first name',
          last_name: 'last name',
          email: 'email@email.com',
          password: '123456'
        )
      expect(user.email_verified?).to eq(false)
    end

    it 'should not have a trader account' do
      user =
        User.create!(
          first_name: 'first name',
          last_name: 'last name',
          email: 'email@email.com',
          password: '123456'
        )
      expect(user.trade_verified?).to eq(false)
    end
  end
end
