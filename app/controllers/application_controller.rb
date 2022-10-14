class ApplicationController < ActionController::API
  include JsonWebToken

  before_action :authenticate_request

  private

  def authenticate_request
    header = request.headers['Authorization']
    if header
      access_token = header.split(' ').last
      begin
        decoded = JsonWebToken.decode(access_token)
        @current_user = User.find(decoded[:user_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: { message: 'Record not found' } }, status: :not_found
      rescue JWT::ExpiredSignature
        render json: { error: { message: 'Session has expired. Sign in to continue.' } }, status: :unauthorized
      rescue JWT::DecodeError
        render json: { error: { message: 'Token invalid.' } }, status: :unprocessable_entity
      end
    else
      render json: { error: { message: 'Please sign in to continue.' } }
    end
  end

  def admin_role
    Role.find(2)
  end

  def user_role
    Role.find(1)
  end

  def admin_request
    current_role = @current_user.roles.first
    return current_role == admin_role ? true : false
  end

  def user_request
    current_role = @current_user.roles.first
    return current_role == user_role ? true : false
  end

  def restrict_admin
    render json: { error: { message: 'Request Forbidden.' } }, status: :forbidden if admin_request
  end

  def restrict_user
    render json: { error: { message: 'Request Forbidden.' } }, status: :forbidden if user_request
  end
end
