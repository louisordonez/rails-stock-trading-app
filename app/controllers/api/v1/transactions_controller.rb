class Api::V1::TransactionsController < ApplicationController
  before_action :restrict_user, except: [:user_index]
  before_action :restrict_admin, only: [:user_index]
  before_action :set_user, only: [:show_index]

  def user_index
    @transactions = @current_user.stock_transactions
    render json: @transactions, status: :ok
  end

  def admin_index
    @transactions = StockTransaction.all
    render json: @transactions, status: :ok
  end

  def show_index
    @transactions = @user.stock_transactions
    render json: @transactions, status: :ok
  end

  private

  def set_user
    begin
      @user = User.find(params[:id])
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
