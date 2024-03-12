class AppStoreClient
  include HTTParty
  headers 'Content-Type' => 'application/json'

  def post(message)
    response = self.class.post("#{host}/v1/application/", **options(message))

    case response.code
    when 201
      :success
    when 409
      # can be ignored but should be notified so we can track when it occurs
      Sentry.capture_message("Application ID already exists in AppStore for '#{message[:application_id]}'")
      :warning
    else
      raise "Unexpected response from AppStore - status #{response.code} for '#{message[:application_id]}'"
    end
  end

  def get_all(since:, count: 20)
    process_get("#{host}/v1/applications?since=#{since.to_i}&count=#{count}")
  end

  def get(submission_id)
    process_get("#{host}/v1/application/#{submission_id}")
  end

  private

  def process_get(url)
    response = self.class.get(url, **options)

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
