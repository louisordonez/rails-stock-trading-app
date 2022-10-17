class Api::V1::PortfoliosController < ApplicationController
  def show
    @portfolios = @current_user.portfolios
    render json: @portfolios, status: :ok
  end
end
