class Api::V1::StocksController < ApplicationController
  include Transaction::Stock

  before_action :restrict_admin
  before_action :trade_verified?, :set_current, except: %i[info most_active get_symbols]
  before_action :set_IEX, except: %i[most_active get_symbols]

  def info
    render json: { company: @company, logo: @logo, quote: @quote }, status: :ok
  end

  def most_active
    client = IEX::Api::Client.new
    most_active = client.stock_market_list(:mostactive)
    render json: { most_active: most_active }, status: :ok
  end

  def get_symbols
    client = IEX::Api::Client.new
    symbols = client.ref_data_symbols()
    render json: { symbols: symbols }, status: :ok
  end

  def buy
    quantity = params[:stock_quantity].to_d
    if quantity == 0
      render json: { error: { message: 'Stock quantity must be greater than zero.' } }, status: :unprocessable_entity
    else
      price = @quote.latest_price
      total = price * quantity
      if @wallet.balance >= total
        buy_params = { quantity: quantity, price: price, total: total, symbol: @symbol, quote: @quote }
        response = Transaction::Stock.buy(@wallet, @portfolios, buy_params)
        render json: response, status: :ok
      else
        render json: {
                 wallet: @wallet,
                 error: {
                   message: 'You have insufficient funds to make this purchase.'
                 }
               },
               status: :unprocessable_entity
      end
    end
  end

  def sell
    quantity = params[:stock_quantity].to_d
    if quantity == 0
      render json: { error: { message: 'Stock quantity must be greater than zero.' } }, status: :unprocessable_entity
    else
      price = @quote.latest_price
      total = price * quantity
      @portfolio = @portfolios.find_by(stock_symbol: @symbol)
      if @portfolio
        if @portfolio.stocks_owned_quantity >= quantity
          sell_params = { quantity: quantity, price: price, total: total, symbol: @symbol }
          response = Transaction::Stock.sell(@wallet, @portfolio, sell_params)
          render json: response, status: :ok
        else
          render json: {
                   portfolio: @portfolio,
                   error: {
                     message: "You have insufficient #{@symbol} stocks to make this sale."
                   }
                 },
                 status: :unprocessable_entity
        end
      else
        render json: {
                 error: {
                   message: "#{@symbol} Stock does not exist in your portfolio."
                 }
               },
               status: :unprocessable_entity
      end
    end
  end

  private

  def trade_verified?
    if !@current_user.trade_verified
      render json: { error: { message: 'Account needs to be verified for trading.' } }, status: :forbidden
    end
  end

  def set_IEX
    @symbol = params[:symbol].strip.upcase
    client = IEX::Api::Client.new
    begin
      @company = client.company(@symbol)
      @logo = client.logo(@symbol)
      @quote = client.quote(@symbol)
    rescue IEX::Errors::SymbolNotFoundError
      render json: { error: { message: 'Symbol not found.' } }, status: :not_found
    rescue IEX::Errors::ClientError
      render json: {
               error: {
                 message: 'Something went wrong. Could not retrieve requested information.'
               }
             },
             status: :service_unavailable
    end
  end

  def set_current
    @wallet = @current_user.wallet
    @portfolios = @current_user.portfolios
  end
end
