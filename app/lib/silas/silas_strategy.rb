module Silas
  class SilasStrategy < OmniAuth::Strategies::EntraId
    info { { email:, roles:, office_codes: } }

    private

    # The `LAA_ACCOUNTS` custom claim can be either a single office code (as a string)
    # or multiple office codes (as an array). Here we normalizes the value to always
    # return an array.
    def office_codes
      [*@raw_info.fetch('LAA_ACCOUNTS')]
    end

    def email
      @raw_info.fetch('email')
    end

    def roles
      [] # Can't get them just yet
    end

    class << self
      def mock_auth
        OmniAuth::AuthHash.new(
          provider: 'entra_id',
          uid: 'test-user',
          info: {
            email: 'provider@example.com',
            roles: ['EFORMS'], # Unknown yet what shape roles take
            office_codes: %w[1A123B 2A555X 3B345C 4C567D]
          }
        )
      end
    end
  end
end
