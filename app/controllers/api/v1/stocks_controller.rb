class Api::V1::StocksController < ApplicationController
  before_action :restrict_admin
  before_action :trade_verified?, except: [:info]

  def info
    symbol = params[:symbol]
    client = IEX::Api::Client.new
    begin
      company = client.company(symbol)
      logo = client.logo(symbol)
      quote = client.quote(symbol)
    rescue IEX::Errors::SymbolNotFoundError
      render json: { error: { message: 'Symbol not found' } }
    rescue IEX::Errors::ClientError
      render json: { error: { message: 'Something went wrong. Could not retrieve requested information.' } }
    else
      render json: { company: company, logo: logo, quote: quote }
    end
  end

  private

  def trade_verified?
    if !@current_user.trade_verified
      render json: { error: { message: 'Account needs to verified for trading.' } }, status: :forbidden
    end
  end
end
