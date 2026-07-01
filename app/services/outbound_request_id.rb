require 'request_store'

class OutboundRequestId
  STORE_KEY = :outbound_request_id
  SERVICE_PREFIX = 'nscc-submit'.freeze

  class << self
    def set(request_id)
      RequestStore.store[STORE_KEY] = request_id.to_s if request_id.present?
    end

    def current
      RequestStore.store[STORE_KEY].presence || "#{SERVICE_PREFIX}-#{SecureRandom.uuid}"
    end

    def headers
      { 'request-id' => current }
    end
  end
end
