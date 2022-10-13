class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [:create_user]
  before_action :set_user, only: %i[show_user update_user destroy_user]

  def index
    @users = User.all
    render json: @users, status: :ok if admin_request
    render json: { error: { message: 'Request Forbidden.' } }, status: :forbidden if user_request
  end

  def show_current
    render json: @current_user, status: :ok
  end

  def show_user
    render json: @user, status: :ok if admin_request
    render json: { error: { message: 'Request Forbidden.' } }, status: :forbidden if user_request
  end

  def create_user
    @user = User.new(user_params)
    if @user.save
      @user.roles << user_role
      new_wallet = Wallet.create(balance: 0)
      WalletTransaction.create(action_type: 'created', total_amount: 0, user: @user, wallet: new_wallet)
      payload = { user_email: @user.email }
      email_token = JsonWebToken.encode(payload, 24.hours.from_now)
      render json: {
               user: @user,
               email_token: email_token,
               message: 'A confirmation email has been sent to verify your account.'
             },
             status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def create_admin
    if admin_request
      @user = User.new(user_params)
      if @user.save
        @user.roles << admin_role
        payload = { user_email: @user.email }
        email_token = JsonWebToken.encode(payload, 24.hours.from_now)
        render json: {
                 user: @user,
                 email_token: email_token,
                 message: 'A confirmation email has been sent to verify your account.'
               },
               status: :created
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end
    render json: { error: { message: 'Request Forbidden.' } }, status: :forbidden if user_request
  end

  def update_current
    if @current_user.update(user_params)
      render json: { user: @current_user, message: 'User account has been updated.' }, status: :ok
    else
      render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_user
    if admin_request
      if @user.roles.first == admin_role
        render json: { error: { message: 'Cannot update Admin account' } }, status: :forbidden
      else
        if @user.update(user_params)
          render json: { user: @user, message: 'User account has been updated.' }, status: :ok
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
    render json: { error: { message: 'Request Forbidden.' } }, status: :forbidden if user_request
  end

  def destroy_current
    @current_user.destroy
    render json: { message: 'User account has been deleted.' }, status: :ok
  end

  def destroy_user
    if admin_request
      if @user.roles.first == admin_role
        render json: { error: { message: 'Cannot delete Admin account' } }, status: :forbidden
      else
        @user.destroy
        render json: { message: 'User account has been deleted.' }, status: :ok
      end
    end
    render json: { error: { message: 'Request Forbidden.' } }, status: :forbidden if user_request
  end

  private

  def set_user
    begin
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: { message: 'Record not found' } }, status: :not_found
    end
  end

  def user_params
    params.permit(:first_name, :last_name, :email, :password)
  end
end
