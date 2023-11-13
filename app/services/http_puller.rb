class HttpPuller
  include HTTParty
  headers 'Content-Type' => 'application/json'

  def get_all(last_update)
    process(:get, "/v1/applications?since=#{last_update.to_i}")
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

    username = ENV.fetch('APP_STORE_USERNAME', nil)
    return options if username.blank?

    options.merge(
      basic_auth: {
        username: username,
        password: ENV.fetch('APP_STORE_PASSWORD')
      }
    )
  end

  def host
    ENV.fetch('APP_STORE_URL', 'http://localhost:8000')
  end
end
