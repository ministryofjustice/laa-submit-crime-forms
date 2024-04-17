class AppStoreClient
  include HTTParty
  headers 'Content-Type' => 'application/json'

  def post(message, path: 'v1/application/')
    response = self.class.post("#{host}/#{path}", **options(message))

    case response.code
    when 200..204
      :success
    when 409
      # can be ignored but should be notified so we can track when it occurs
      Sentry.capture_message("Application ID already exists in AppStore for '#{message[:application_id]}'")
      :warning
    else
      raise "Unexpected response from AppStore - status #{response.code} for '#{message[:application_id]}'"
    end
  end

  def put(message)
    response = self.class.put("#{host}/v1/application/#{message[:application_id]}", **options(message))

    case response.code
    when 201
      :success
    else
      raise "Unexpected response from AppStore - status #{response.code} for '#{message[:application_id]}'"
    end
  end

  def get_all(since:, count: 20)
    process_get("/v1/applications?since=#{since.to_i}&count=#{count}")
  end

  def get(submission_id)
    process_get("/v1/application/#{submission_id}")
  end

  private

  def process_get(path)
    url = "#{host}#{path}"
    response = self.class.get(url, **options)

    case response.code
    when 200
      JSON.parse(response.body)
    else
      raise "Unexpected response from AppStore - status #{response.code} for '#{path}'"
    end
  end

  def options(message = nil)
    options = message ? { body: message.to_json } : {}
    options.merge(headers:)
  end

  def headers
    if AppStoreTokenProvider.instance.authentication_configured?
      {
        authorization: "Bearer #{AppStoreTokenProvider.instance.bearer_token}"
      }
    else
      {
        'X-Client-Type': 'provider'
      }
    end
  end

  def host
    ENV.fetch('APP_STORE_URL', 'http://localhost:8000')
  end
end
