class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [:create]
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
    begin
      render json: @user, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: { message: 'Record not found' } }, status: :not_found
    end
  end

  def create
    @user = User.new(user_params)

    if @user.save
      @user.roles << Role.find(1)
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

  def update
    render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity unless @user.update(user_params)
  end

  def destroy
    @user.destroy
  end

  private

  def set_user
    header = request.headers['Authorization']
    access_token = header.split(' ').last if header
    decoded = JsonWebToken.decode(access_token)
    @user = User.find(decoded[:user_id])
  end

  def user_params
    params.permit(:first_name, :last_name, :email, :password)
  end
end
