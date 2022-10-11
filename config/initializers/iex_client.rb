IEX::Api.configure do |config|
  config.publishable_token = ENV['SANDBOX_PUBLISHABLE_TOKEN']
  config.secret_token = ENV['SANDBOX_SECRET_TOKEN']
  config.endpoint = ENV['SANDBOX_ENDPOINT']
end
