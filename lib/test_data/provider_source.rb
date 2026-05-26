module TestData
  class ProviderSource
    GENERATED_MODE = 'generated'.freeze
    DEV_PROVIDER_ATTRIBUTES = {
      auth_provider: 'entra_id',
      uid: 'test-user',
      email: 'provider@example.com',
      office_codes: %w[1A123B 2A555X],
      first_name: 'Test',
      last_name: 'User'
    }.freeze

    attr_reader :providers, :office_codes

    def self.generated
      new
    end

    def self.from_environment(provider_count:, office_code_count:, env: ENV)
      return generated if env.fetch('PROVIDER_MODE', nil) == GENERATED_MODE
      return generated unless default_dev_provider_shape?(provider_count:, office_code_count:)
      return generated unless HostEnv.local? || HostEnv.development?

      new(providers: [dev_provider], office_codes: DEV_PROVIDER_ATTRIBUTES.fetch(:office_codes))
    end

    def self.default_dev_provider_shape?(provider_count:, office_code_count:)
      provider_count.to_i <= 1 && office_code_count.to_i <= 1
    end
    private_class_method :default_dev_provider_shape?

    def self.dev_provider
      Provider.find_or_initialize_by(
        auth_provider: DEV_PROVIDER_ATTRIBUTES.fetch(:auth_provider),
        uid: DEV_PROVIDER_ATTRIBUTES.fetch(:uid)
      ).tap do |provider|
        provider.assign_attributes(DEV_PROVIDER_ATTRIBUTES)
        provider.save! if provider.changed?
      end
    end
    private_class_method :dev_provider

    def initialize(providers: [], office_codes: [])
      @providers = Array(providers)
      @office_codes = Array(office_codes)
    end

    def generated?
      providers.empty?
    end
  end
end
