# frozen_string_literal: true

class AppStoreTokenProvider
  include Singleton

  def initialize
    oauth_client
  end

  def oauth_client
    @oauth_client ||= OAuth2::Client.new(
      client_id,
      client_secret,
      token_url: "https://login.microsoftonline.com/#{tenant_id}/oauth2/v2.0/token"
    )
  end

  def access_token
    @access_token = new_access_token if @access_token.nil? || @access_token.expired?
    @access_token
  end

  def bearer_token
    access_token.token
  end

  private

  def new_access_token
    oauth_client.client_credentials.get_token(scope: "api://#{client_id}/.default")
  end

  def client_id
    ENV.fetch('APP_STORE_CLIENT_ID', nil)
  end

  def tenant_id
    ENV.fetch('APP_STORE_TENANT_ID', nil)
  end

  def client_secret
    ENV.fetch('APP_STORE_CLIENT_SECRET', nil)
  end
end
