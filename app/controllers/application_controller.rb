class ApplicationController < ActionController::API
  include JsonWebToken

  before_action :authenticate_request

  private

  def authenticate_request
    header = request.headers['Authorization']
    access_token = header.split(' ').last if header
    begin
      decoded = JsonWebToken.decode(access_token)
      @current_user = User.find(decoded[:user_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: { message: 'Record not found' } }, status: :not_found
    rescue JWT::ExpiredSignature
      render json: { error: { message: 'Session has expired. Log in to continue.' } }, status: :unauthorized
    rescue JWT::DecodeError
      render json: { error: { message: 'Token invalid.' } }, status: :unprocessable_entity
    end
  end
end
