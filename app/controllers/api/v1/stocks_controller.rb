class Api::V1::StocksController < ApplicationController
  before_action :restrict_admin
  before_action :trade_verified?, :set_current, except: [:info]
  before_action :set_IEX

  def info
    render json: { company: @company, logo: @logo, quote: @quote }, status: :ok
  end

  def buy
    quantity = params[:stock_quantity].to_d
    price = @quote.latest_price
    total = price * quantity
    if @wallet.balance >= total
      @portfolio = @portfolios.find_by(stock_symbol: @symbol)
      if !@portfolio
        @portfolio = Portfolio.create(stock_name: @quote.company_name, stock_symbol: @symbol, stocks_owned_quantity: 0)
      end
      @transaction =
        StockTransaction.create(
          action_type: 'buy',
          stock_quantity: quantity,
          stock_price: price,
          total_amount: total,
          user: @current_user,
          portfolio: @portfolio
        )
      @portfolio.update(stocks_owned_quantity: @portfolio.stocks_owned_quantity + quantity)
      @wallet.update(balance: @wallet.balance - total)
      render json: {
               user: @current_user,
               wallet: @wallet,
               portfolio: @portfolio,
               transaction: @transaction,
               message: "You have purchased #{quantity} #{@symbol} stocks worth $#{total} at $#{price}/stock."
             },
             status: :ok
    else
      render json: {
               error: {
                 message: 'You have insufficient funds to make this purchase.'
               }
             },
             status: :unprocessable_entity
    end
  end

  def sell
    quantity = params[:stock_quantity].to_d
    price = @quote.latest_price
    total = price * quantity
    @portfolio = @portfolios.find_by(stock_symbol: @symbol)
    if @portfolio
      if @portfolio.stocks_owned_quantity >= quantity
        @transaction =
          StockTransaction.create(
            action_type: 'sell',
            stock_quantity: quantity,
            stock_price: price,
            total_amount: total,
            user: @current_user,
            portfolio: @portfolio
          )
        @portfolio.update(stocks_owned_quantity: @portfolio.stocks_owned_quantity - quantity)
        @wallet.update(balance: @wallet.balance + total)
        render json: {
                 user: @current_user,
                 wallet: @wallet,
                 portfolio: @portfolio,
                 transaction: @transaction,
                 message: "You have sold #{quantity} #{@symbol} stocks worth $#{total} at $#{price}/stock."
               },
               status: :ok
      else
        render json: {
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
      render json: { error: { message: 'Symbol not found' } }, status: :not_found
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
