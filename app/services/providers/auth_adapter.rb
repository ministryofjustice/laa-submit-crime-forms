module Providers
  class AuthAdapter
    ROLES_TOKEN_PATTERN = ','.freeze
    OFFICE_CODES_TOKEN_PATTERN = ':'.freeze

    # SAMLmock lacks email
    FALLBACK_EMAIL = 'provider@example.com'.freeze

    def self.call(auth_hash)
      new(auth_hash).transform
    end

    def initialize(auth_hash)
      @auth_hash = auth_hash
    end
    private_class_method :new

    def transform
      Rails.logger.warn auth_info
      Rails.logger.warn @auth_hash.info
      @auth_hash.merge(
        info: {
          email:,
          roles:,
          office_codes:
        }
      )
    end

    private

    def email
      auth_info.email.presence || FALLBACK_EMAIL
    end

    def roles
      auth_info.roles.to_s.split(ROLES_TOKEN_PATTERN)
    end

    def office_codes
      auth_info.office_codes.to_s.split(OFFICE_CODES_TOKEN_PATTERN)
    end

    def auth_info
      Rails.logger.warn @auth_hash
      @auth_hash.info
    end
  end
end
