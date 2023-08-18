class NotifyAppStore
  class HttpNotifier
    include HTTParty

    def post(message)
      self.class.post("#{host}/application/", message).parsed_response
    end

    private

    def host
      ENV.fetch('APP_STORE_URL', 'http://localhost:8000')
    end
  end
end
