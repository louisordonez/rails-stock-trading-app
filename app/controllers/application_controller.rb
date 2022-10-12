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

  def admin_request
    admin_role = Role.find(2)
    current_role = @current_user.roles.first
    return current_role == admin_role ? true : false
  end

  def user_request
    user_role = Role.find(1)
    current_role = @current_user.roles.first
    return current_role == user_role ? true : false
  end
end
