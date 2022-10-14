class Api::V1::AuthenticationController < ApplicationController
  skip_before_action :authenticate_request, except: [:verify_trade]
  before_action :restrict_user, :set_user, only: [:verify_trade]

  def sign_in
    @user = User.find_by_email(params[:email])
    if (@user&.authenticate(params[:password]))
      payload = { user_id: @user.id }
      exp = 7.days.from_now.to_i
      access_token = JsonWebToken.encode(payload, exp)
      render json: { user: @user, expiration: exp, access_token: access_token }, status: :ok
    else
      render json: { error: { message: 'Invalid login credentials' } }, status: :unauthorized
    end
  end

  def verify_email
    token = params[:token]
    begin
      decoded = JsonWebToken.decode(token)
      @user = User.find_by_email(decoded[:user_email])
      raise ActiveRecord::RecordNotFound if !@user
    rescue ActiveRecord::RecordNotFound
      render json: { error: { message: 'Record not found' } }, status: :not_found
    rescue JWT::ExpiredSignature
      render json: {
               error: {
                 message: 'Confirmation invalid. Verification token has expired'
               }
             },
             status: :unprocessable_entity
    rescue JWT::DecodeError
      render json: { error: { message: 'Token invalid.' } }, status: :unprocessable_entity
    else
      if @user.email_verified
        render json: { message: 'Account has already been verified.' }, status: :accepted
      else
        @user.update(email_verified: true)
        render json: { user: @user, message: 'Email confirmed. Account has been verified.' }, status: :ok
      end
    end
  end

  def request_email_token
    header = request.headers['Authorization']
    if header
      access_token = header.split(' ').last
      begin
        decoded = JsonWebToken.decode(access_token)
        @user = User.find(decoded[:user_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: { message: 'Record not found' } }, status: :not_found
      else
        if @user.email_verified
          render json: { message: 'Account has already been verified.' }, status: :accepted
        else
          payload = { user_email: @user.email }
          new_token = JsonWebToken.encode(payload, 24.hours.from_now)
          render json: {
                   email_token: new_token,
                   message: 'A confirmation email has been sent to verify your account.'
                 },
                 status: :ok
        end
      end
    else
      render json: { error: { message: 'Please sign in to continue.' } }
    end
  end

  def verify_trade
    if @user.trade_verified
      render json: { message: 'Account has already been approved for trading.' }
    else
      @user.update(trade_verified: true)
      render json: { user: @user, message: 'Account has been approved for trading.' }
    end
  end

  def check_role
    header = request.headers['Authorization']
    if header
      access_token = header.split(' ').last
      begin
        decoded = JsonWebToken.decode(access_token)
        @user = User.find(decoded[:user_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: { message: 'Record not found' } }, status: :not_found
      rescue JWT::ExpiredSignature
        render json: { error: { message: 'Session has expired. Log in to continue.' } }, status: :unauthorized
      rescue JWT::DecodeError
        render json: { error: { message: 'Token invalid.' } }, status: :unprocessable_entity
      else
        render json: { role: @user.roles.first.name }
      end
    else
      render json: { error: { message: 'Please sign in to continue.' } }
    end
  end

  private

  def set_user
    begin
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: { message: 'Record not found' } }, status: :not_found
    end
  end
end
