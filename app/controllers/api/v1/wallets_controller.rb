class Api::V1::WalletsController < ApplicationController
  before_action :restrict_admin, :current_wallet, except: [:show_wallet]
  before_action :restrict_user, :set_wallet, only: [:show_wallet]

  def show
    render json: { wallet: @wallet, transactions: @wallet.wallet_transactions }
  end

  def show_wallet
    render json: { wallet: @wallet, transactions: @wallet.wallet_transactions }
  end

  def deposit
    wallet_transaction =
      @wallet.wallet_transactions.create(action_type: 'deposit', total_amount: params[:total_amount].to_d)
    @wallet.update(balance: @wallet.balance + params[:total_amount].to_d)
    render json: {
             user: @current_user,
             wallet: @wallet,
             transaction: wallet_transaction,
             message: "Deposited $#{params[:total_amount]} to your account."
           }
  end

  def withdraw
    if @wallet.balance >= params[:total_amount].to_d
      wallet_transaction =
        @wallet.wallet_transactions.create(action_type: 'withdrawal', total_amount: params[:total_amount].to_d)
      @wallet.update(balance: @wallet.balance - params[:total_amount].to_d)
      render json: {
               user: @current_user,
               wallet: @wallet,
               transaction: wallet_transaction,
               message: "Withdrawn $#{params[:total_amount]} from your account."
             }
    else
      render json: { error: { message: 'You have insufficient funds.' } }
    end
  end

  private

  def current_wallet
    @wallet = @current_user.wallet
  end

  def set_wallet
    begin
      @wallet = Wallet.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: { message: 'Record not found' } }, status: :not_found
    end
  end
end
