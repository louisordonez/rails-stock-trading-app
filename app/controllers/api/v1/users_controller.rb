class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [:create]
  before_action :set_user, only: %i[show destroy]

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
      render json: @user, status: :created
    else
      render json: {
               errors: @user.errors.full_messages
             },
             status: :unprocessable_entity
    end
  end

  def update
    unless @user.update(user_params)
      ender json: {
              errors: @user.errors.full_messages
            },
            status: :unprocessable_entity
    end
  end

  def destory
    @user.destory
  end

  private

  def user_params
    params.permit(:first_name, :last_name, :email, :password)
  end

  def set_user
    @user = User.find(params[:id])
  end
end
