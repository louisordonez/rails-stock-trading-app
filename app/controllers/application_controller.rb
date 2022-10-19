require 'sprockets/railtie'
class ApplicationController < ActionController::API
  include JsonWebToken

  before_action :authenticate_request, :email_verified?

  FINTRADER_FRONTED_URL = 'https://react-stock-trading-app.vercel.app'

  private

  def admin_role
    Role.find(2)
  end

  def user_role
    Role.find(1)
  end

  def restrict_admin
    if @current_user.roles.first == admin_role
      render json: { error: { message: 'Request Forbidden.' } }, status: :forbidden
    end
  end

  def restrict_user
    if @current_user.roles.first == user_role
      render json: { error: { message: 'Request Forbidden.' } }, status: :forbidden
    end
  end

  def authenticate_request
    header = request.headers['Authorization']
    if header
      access_token = header.split(' ').last
      begin
        decoded = JsonWebToken.decode(access_token)
        @current_user = User.find(decoded[:user_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: { message: 'Record not found.' } }, status: :not_found
      rescue JWT::ExpiredSignature
        render json: { error: { message: 'Session has expired. Sign in to continue.' } }, status: :unauthorized
      rescue JWT::DecodeError
        render json: { error: { message: 'Token invalid.' } }, status: :unprocessable_entity
      end
    else
      render json: { error: { message: 'Please sign in to continue.' } }, status: :forbidden
    end
  end

  def email_verified?
    if !@current_user.email_verified
      render json: { error: { message: 'Account needs to be verified to continue.' } }, status: :forbidden
    end
  end
end
