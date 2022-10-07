class Api::V1::AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def sign_in
    @user = User.find_by_email(params[:email])
    if (@user&.authenticate(params[:password]))
      if @user.email_verified
        payload = { user_id: @user.id }
        access_token = JsonWebToken.encode(payload)
        render json: { user: @user, 'access-token': access_token }, status: :ok
      else 
        render json: { error: { message: "Account needs to be verified." } }, status: :unauthorized
      end
    else
      render json: { error: 'unathorized' }, status: :unauthorized
    end
  end

  def verify_token
    token = params[:token]
    begin
      decoded = JsonWebToken.decode(token)
      @user = User.find_by_email(decoded[:user_email])
      if @user.email_verified
        render json: { message: "Account has already been verified." }, status: :accepted
      else
        @user.update(email_verified: true)
        render json: { user: @user, message: "Email confirmed. Account has been verified." }, status: :ok
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: { message: "Record not found" } }, status: :not_found
    rescue JWT::ExpiredSignature
      render json: { error: { message: "Confirmation invalid. Verification token has expired" } }, status: :unprocessable_entity
    rescue JWT::DecodeError
      render json: { error: { message: "Token invalid." } }, status: :unprocessable_entity
    end
  end

  def request_token
    email = params[:email]
    begin
      @user = User.find_by_email(email)
      if @user.email_verified
        render json: { message: "Account has already been verified." }, status: :accepted
      else 
        payload: { user_email: @user.email }
        new_token = JsonWebToken.encode(payload, 24.hours.from_now)
        render json: { email_token: new_token, message: "A confirmation email has been sent to verify your account." }, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: { error: { message: "Record not found" } }, status: :not_found
    end
  end
end
