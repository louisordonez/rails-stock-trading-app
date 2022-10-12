class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [:create_user]
  before_action :set_user, only: %i[show update destroy]

  def index
    if admin_request
      @users = User.all
      render json: @users, status: :ok
    else
      render json: { error: { message: 'Request Forbidden.' } }, status: :forbidden
    end
  end

  def show
    if admin_request
      render json: @user, status: :ok
    elsif user_request
      if @current_user == @user
        render json: @user, status: :ok
      else
        render json: { error: { message: 'Request Forbidden.' } }, status: :forbidden
      end
    end
  end

  def create_user
    @user = User.new(user_params)
    if @user.save
      @user.roles << user_role
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
    elsif user_request
      render json: { error: { message: 'Request Forbidden.' } }, status: :forbidden
    end
  end

  def update
    if admin_request
      unless @user.update(user_params)
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    elsif user_request
      if @current_user == @user
        unless @user.update(user_params)
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { error: { message: 'Request Forbidden.' } }, status: :forbidden
      end
    end
  end

  def destroy
    @user.destroy
  end

  private

  # def set_user
  #   header = request.headers['Authorization']
  #   access_token = header.split(' ').last if header
  #   decoded = JsonWebToken.decode(access_token)
  #   @user = User.find(decoded[:user_id])
  # end

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
