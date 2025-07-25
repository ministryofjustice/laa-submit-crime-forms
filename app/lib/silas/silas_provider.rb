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

    # Compute the authorize_params needed based on application state
    # prompt: 'none' is needed for silent authentication
    # prompt: 'select_account' is the other likely option that takes
    # users to the account selection dialog in Entra
    def authorize_params
      ap = {
        prompt: 'none'
      }

      if @strategy.request
        ap[:prompt] = @strategy.request.params[:prompt] if @strategy.request.params[:prompt]
        login_hint = @strategy.request.cookies[:login_hint] || @strategy.request.params[:login_hint]

        if login_hint
          ap[:login_hint] = login_hint
          ap[:prompt] = 'none'
        end
      end
      ap
    end

    private

    def certificate_path
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
  end
end
