module Silas
  class SilasProvider
    def initialize(strategy)
      @strategy = strategy
    end

    def tenant_id
      ENV.fetch('ENTRA_TENANT_ID', nil)
    end

    def client_id
      ENV.fetch('ENTRA_CLIENT_ID', nil)
    end

    def client_secret
      ENV.fetch('ENTRA_CLIENT_SECRET', nil)
    end

    def authorize_params
      {
        prompt: 'select_account'
      }
    end

    def certificate_path
      return if client_secret.present?

      cert_path = Rails.root.join('tmp', 'omniauth-cert.p12')
      cert_data = ENV.fetch('ENTRA_CERTIFICATE_DATA', nil)

      return cert_path if File.exist?(cert_path)
      return nil if cert_data.blank?

      cert_data = Base64.strict_decode64(cert_data)
      File.binwrite(cert_path, cert_data)
      File.chmod(0o600, cert_path)

      at_exit { FileUtils.rm_f(cert_path) }

      cert_path
    end

    def respond_to?(method_name, include_private: false)
      case method_name.to_sym
      when :certificate_path
        return ENV['ENTRA_CLIENT_SECRET'].blank?
      end

      super
    end
  end
end
