class HttpPuller
  include HTTParty
  headers 'Content-Type' => 'application/json'

  def get_all(since:, count: 20)
    process(:get, "/v1/applications?since=#{since.to_i}&count=#{count}")
  end

  private

  def process(method, url)
    response = self.class.public_send(method, "#{host}#{url}", **options)

    case response.code
    when 200
      JSON.parse(response.body)
    else
      raise "Unexpected response from AppStore - status #{response.code} for '#{url}'"
    end
  end

  def options
    options = {}

    return options unless AppStoreTokenProvider.instance.authentication_configured?

    token = AppStoreTokenProvider.instance.bearer_token

    options.merge(
      headers: {
        authorization: "Bearer #{token}"
      }
    )
  end

  def host
    ENV.fetch('APP_STORE_URL', 'http://localhost:8000')
  end
end
