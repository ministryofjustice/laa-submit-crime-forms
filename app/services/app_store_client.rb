class AppStoreClient
  include HTTParty

  headers 'Content-Type' => 'application/json'

  def post(message, path: 'v1/application/')
    response = self.class.post("#{host}/#{path}", **options(message))

    case response.code
    when 200..204
      response.body.present? ? JSON.parse(response.body) : :success
    when 409
      raise "Application ID already exists in AppStore for '#{message[:application_id]}'"
    else
      raise "Unexpected response from AppStore - status #{response.code} for '#{message[:application_id]}'"
    end
  end

  def put(message, client_type: :provider)
    response = self.class.put("#{host}/v1/application/#{message[:application_id]}", **options(message, client_type:))

    case response.code
    when 201
      JSON.parse(response.body)
    else
      raise "Unexpected response from AppStore - status #{response.code} for '#{message[:application_id]}'"
    end
  end

  def get(submission_id)
    url = "#{host}/v1/application/#{submission_id}"
    response = self.class.get(url, **options)
    process_response(response, url)
  end

  def search(payload)
    url = "#{host}/v1/submissions/searches"
    response = self.class.post(url, **options(payload))

    process_response(response, url)
  end

  def post_import_error(message)
    url = "#{host}/v1/failed_imports"
    response = self.class.post(url, **options(message))

    case response.code
    when 201
      JSON.parse(response.body)
    else
      raise "Unexpected response from AppStore - status #{response.code} for '#{message[:id]}'"
    end
  end

  def get_import_error(error_id)
    url = "#{host}/v1/failed_imports/#{error_id}"
    response = self.class.get(url, **options)
    process_response(response, url)
  end

  private

  def process_response(response, url)
    case response.code
    when 200..204
      JSON.parse(response.body)
    else
      raise "Unexpected response from AppStore - status #{response.code} for '#{url}'"
    end
  end

  def options(message = nil, client_type: :provider)
    options = message ? { body: message.to_json } : {}
    options.merge(headers: headers(client_type:))
  end

  def headers(client_type: :provider)
    if AppStoreTokenProvider.instance.authentication_configured?
      raise 'AppStore client type override is only supported without OAuth' unless client_type.to_sym == :provider

      {
        authorization: "Bearer #{AppStoreTokenProvider.instance.bearer_token}"
      }
    else
      {
        'X-Client-Type': client_type.to_s
      }
    end
  end

  def host
    ENV.fetch('APP_STORE_URL', 'http://localhost:8000')
  end
end
