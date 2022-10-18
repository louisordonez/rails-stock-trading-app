class Api::V1::PortfoliosController < ApplicationController
  def show
    @portfolios = @current_user.portfolios.uniq
    render json: @portfolios, status: :ok
  end
end
