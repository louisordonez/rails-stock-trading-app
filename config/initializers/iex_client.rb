IEX::Api.configure do |config|
  # ENV
  # config.publishable_token = ENV['PRODUCTION_PUBLISHABLE_TOKEN']
  # config.secret_token = ENV['PRODUCTION_SECRET_TOKEN']
  # config.endpoint = ENV['PRODUCTION_ENDPOINT']

  # config.publishable_token = ENV['SANDBOX_PUBLISHABLE_TOKEN']
  # config.secret_token = ENV['SANDBOX_SECRET_TOKEN']
  # config.endpoint = ENV['SANDBOX_ENDPOINT']

  # Rails Credentials
  config.publishable_token = Rails.application.credentials.iex.production.publishable_token
  config.secret_token = Rails.application.credentials.iex.production.secret_token
  config.endpoint = Rails.application.credentials.iex.production.endpoint

  # config.publishable_token = Rails.application.credentials.iex.sandbox.publishable_token
  # config.secret_token = Rails.application.credentials.iex.sandbox.secret_token
  # config.endpoint = Rails.application.credentials.iex.sandbox.endpoint
end
