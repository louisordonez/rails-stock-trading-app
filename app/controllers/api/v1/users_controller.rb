class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [:create]
  before_action :set_user, only: %i[show update destroy]

  def index
    @users = User.all

    render json: @users, status: :ok
  end

  def show
    render json: @user, status: :ok
  end

  def create
    @user = User.new(user_params)

    if @user.save
      payload = { user_email: @user.email }
      email_token = JsonWebToken.encode(payload, 30.minutes.from_now)
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
    @user = User.find(params[:id])
  end

  def user_params
    params.permit(:first_name, :last_name, :email, :password)
  end
end
