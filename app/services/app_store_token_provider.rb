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
    create_composite_token
  end

  def authentication_configured?
    tenant_id.present?
  end

  private

  def new_access_token
    oauth_client.client_credentials.get_token(
      scope: "api://#{app_store_client_id}/.default"
    )
  end

  def create_composite_token
    payload = {
      entra_token: access_token.token,
      email: GlobalContext.current_user&.email,
      exp: 1.hour.from_now.to_i
    }

    JWT.encode(payload, client_secret, 'HS256')
  end

  def client_id
    ENV.fetch('PROVIDER_CLIENT_ID', nil)
  end

  def app_store_client_id
    ENV.fetch('APP_STORE_CLIENT_ID', nil)
  end

  def tenant_id
    ENV.fetch('APP_STORE_TENANT_ID', nil)
  end

  def client_secret
    ENV.fetch('PROVIDER_CLIENT_SECRET', nil)
  end
end
