class Api::V1::WalletsController < ApplicationController
  include Transaction::Wallet

  before_action :restrict_admin, :current_wallet, except: [:show_wallet]
  before_action :restrict_user, :set_wallet, only: [:show_wallet]

  def show
    render json: { wallet: @wallet, transactions: @wallet.wallet_transactions }
  end

  def show_wallet
    render json: { wallet: @wallet, transactions: @wallet.wallet_transactions }
  end

  def deposit
    total_amount = params[:total_amount].to_d
    if total_amount == 0
      render json: {
               error: {
                 message: 'Total amount must be greater than zero.'
               }
             },
             status: :unprocessable_entity
    else
      response = Transaction::Wallet.deposit(@wallet, total_amount)
      render json: response, status: :ok
    end
  end

  def withdraw
    total_amount = params[:total_amount].to_d
    if total_amount == 0
      render json: {
               error: {
                 message: 'Total amount must be greater than zero.'
               }
             },
             status: :unprocessable_entity
    else
      if @wallet.balance >= total_amount
        response = Transaction::Wallet.withdraw(@wallet, total_amount)
        render json: response, status: :ok
      else
        render json: {
                 error: {
                   message: 'You have insufficient funds.'
                 }
               },
               status: :unprocessable_entity
      end
    end
  end

  private

  def current_wallet
    @wallet = @current_user.wallet
  end

  def set_wallet
    begin
      @wallet = User.find(params[:id]).wallet
    rescue ActiveRecord::RecordNotFound
      render json: {
               error: {
                 message: 'Record not found'
               }
             },
             status: :not_found
    end
  end
end
