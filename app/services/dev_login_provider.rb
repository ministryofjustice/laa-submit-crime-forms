class DevLoginProvider
  AUTH_PROVIDER = 'entra_id'.freeze
  UID = 'test-user'.freeze
  EMAIL = 'provider@example.com'.freeze
  OFFICE_CODES = %w[1A123B 2A555X].freeze
  FIRST_NAME = 'Test'.freeze
  LAST_NAME = 'User'.freeze

  class << self
    def find_or_create!
      Provider.find_or_initialize_by(auth_provider: AUTH_PROVIDER, uid: UID).tap do |provider|
        provider.assign_attributes(attributes)
        provider.save! if provider.changed?
      end
    end

    def info
      attributes.slice(:email, :office_codes, :first_name, :last_name)
    end

    private

    def attributes
      {
        auth_provider: AUTH_PROVIDER,
        uid: UID,
        email: EMAIL,
        office_codes: OFFICE_CODES,
        first_name: FIRST_NAME,
        last_name: LAST_NAME
      }
    end
  end
end
