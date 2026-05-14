module TestData
  class ProviderSource
    GENERATED_MODE = 'generated'.freeze
    DEV_LOGIN_MODE = 'dev_login'.freeze
    DEV_LOGIN_MODE_ALIASES = [DEV_LOGIN_MODE, 'dev', 'default_dev'].freeze
    PROVIDER_MODE_ERROR = 'PROVIDER_MODE supports dev_login or generated'.freeze
    GENERATED_WITH_SELECTION_ERROR = 'PROVIDER_EMAIL, PROVIDER_UID, and OFFICE_CODES cannot be used ' \
                                     'with PROVIDER_MODE=generated'.freeze

    attr_reader :providers, :office_codes, :mode

    def self.generated
      new(mode: GENERATED_MODE)
    end

    def self.from_environment(provider_count:, office_code_count:, env: ENV)
      new.from_environment(provider_count:, office_code_count:, env:)
    end

    def initialize(providers: [], office_codes: [], mode: GENERATED_MODE)
      @providers = Array(providers)
      @office_codes = Array(office_codes)
      @mode = mode
    end

    def generated?
      providers.empty?
    end

    def from_environment(provider_count:, office_code_count:, env: ENV)
      mode = provider_mode(env)

      return generated_source(env) if mode == GENERATED_MODE
      return explicit_source(env) if explicit_selection?(env)
      return dev_login_source(env) if dev_login_mode?(mode) || default_dev_login?(provider_count:, office_code_count:)

      self.class.generated
    end

    private

    def provider_mode(env)
      env_value(env, 'PROVIDER_MODE').tap do |mode|
        raise ArgumentError, PROVIDER_MODE_ERROR if mode.present? && unsupported_mode?(mode)
      end
    end

    def generated_source(env)
      raise ArgumentError, GENERATED_WITH_SELECTION_ERROR if explicit_selection?(env)

      self.class.generated
    end

    def explicit_source(env)
      selected_source_for(provider_from_env(env) || DevLoginProvider.find_or_create!, env, mode: :selected)
    end

    def dev_login_source(env)
      selected_source_for(DevLoginProvider.find_or_create!, env, mode: DEV_LOGIN_MODE)
    end

    def selected_source_for(provider, env, mode:)
      office_codes = office_codes_for(provider, env)

      self.class.new(providers: [provider], office_codes: office_codes, mode: mode)
    end

    def provider_from_env(env)
      provider_email = env_value(env, 'PROVIDER_EMAIL')
      provider_uid = env_value(env, 'PROVIDER_UID')
      return if provider_email.blank? && provider_uid.blank?

      providers = Provider.all
      providers = providers.where(email: provider_email) if provider_email.present?
      providers = providers.where(uid: provider_uid) if provider_uid.present?
      provider = providers.first

      return provider if provider

      raise ArgumentError, provider_not_found_message(provider_email:, provider_uid:)
    end

    def provider_not_found_message(provider_email:, provider_uid:)
      identifiers = { PROVIDER_EMAIL: provider_email, PROVIDER_UID: provider_uid }.compact_blank
      "No provider found for #{identifiers.map { |key, value| "#{key}=#{value}" }.join(', ')}"
    end

    def office_codes_for(provider, env)
      office_codes = office_codes_from_env(env).presence || provider.office_codes
      unsupported_office_codes = office_codes - provider.office_codes

      return office_codes if unsupported_office_codes.empty?

      raise ArgumentError, 'OFFICE_CODES must belong to the selected provider. ' \
                           "Unsupported office codes: #{unsupported_office_codes.join(', ')}"
    end

    def office_codes_from_env(env)
      env_value(env, 'OFFICE_CODES').to_s.split(',').map(&:strip).compact_blank
    end

    def explicit_selection?(env)
      %w[PROVIDER_EMAIL PROVIDER_UID OFFICE_CODES].any? { |key| env_value(env, key).present? }
    end

    def unsupported_mode?(mode)
      mode != GENERATED_MODE && DEV_LOGIN_MODE_ALIASES.exclude?(mode)
    end

    def dev_login_mode?(mode)
      DEV_LOGIN_MODE_ALIASES.include?(mode)
    end

    def default_dev_login?(provider_count:, office_code_count:)
      dev_like_environment? && provider_count.to_i <= 1 && office_code_count.to_i <= 1
    end

    def dev_like_environment?
      HostEnv.local? || HostEnv.development?
    rescue KeyError
      false
    end

    def env_value(env, key)
      env.fetch(key, nil).presence
    end
  end
end
