class Api::V1::WalletsController < ApplicationController
  before_action :restrict_admin, :current_wallet, except: [:show_wallet]
  before_action :restrict_user, :set_wallet, only: [:show_wallet]

  def show
    @wallet_transactions = @wallet.wallet_transactions
    render json: { wallet: @wallet, transactions: @wallet_transactions }
  end

  def show_wallet
    @wallet_transactions = @wallet.wallet_transactions
    render json: { wallet: @wallet, transactions: @wallet_transactions }
  end

  def deposit
    WalletTransaction.create(
      action_type: 'deposit',
      total_amount: params[:total_amount].to_d,
      user: @current_user,
      wallet: @wallet
    )
    @wallet.update(balance: @wallet.balance + params[:total_amount].to_d)
    render json: {
             user: @current_user,
             wallet: @wallet,
             message: "Deposited $#{params[:total_amount]} to your account."
           }
  end

  def withdraw
    if @wallet.balance >= params[:total_amount].to_d
      WalletTransaction.create(
        action_type: 'withdrawal',
        total_amount: params[:total_amount].to_d,
        user: @current_user,
        wallet: @wallet
      )
      @wallet.update(balance: @wallet.balance - params[:total_amount].to_d)
      render json: {
               user: @current_user,
               wallet: @wallet,
               message: "Withdrawn $#{params[:total_amount]} from your account."
             }
    else
      render json: { error: { message: 'You have insufficient funds.' } }
    end
  end

  private

  def current_wallet
    @wallet = @current_user.wallets.first
  end

  def set_wallet
    begin
      @wallet = Wallet.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: { message: 'Record not found' } }, status: :not_found
    end
  end
end
