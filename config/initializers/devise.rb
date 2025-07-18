# frozen_string_literal: true

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

Devise.setup do |config|
  require 'devise/orm/active_record'
  require Rails.root.join('app/lib/silas/silas_strategy')

  # ==> Configuration for :timeoutable
  # The time you want to timeout the user session without activity. After this
  # time the user will be asked for credentials again. Default is 30 minutes.
  config.timeout_in = Rails.configuration.x.auth.timeout_in

  # ==> Configuration for :lockable
  # Defines which strategy will be used to lock an account.
  # :failed_attempts = Locks an account after a number of failed attempts to sign in.
  # :none            = No lock strategy. You should handle locking by yourself.
  config.lock_strategy = :none

  # Defines which key will be used when locking and unlocking an account
  # config.unlock_keys = [:email]

  # Defines which strategy will be used to unlock an account.
  # :email = Sends an unlock link to the user email
  # :time  = Re-enables login after a certain amount of time (see :unlock_in below)
  # :both  = Enables both strategies
  # :none  = No unlock strategy. You should handle unlocking by yourself.
  config.unlock_strategy = :none

  # Number of authentication tries before locking an account if lock_strategy
  # is failed attempts.
  # config.maximum_attempts = 20

  # Time interval to unlock the account if :time is enabled as unlock_strategy.
  # config.unlock_in = 1.hour

  # Warn on the last attempt before the account is locked.
  # config.last_attempt_warning = true

  # Configure the default scope given to Warden. By default it's the first
  # devise role declared in your routes (usually :user).
  config.default_scope = :provider

  # Set this configuration to false if you want /users/sign_out to sign out
  # only the current scope. By default, Devise signs out all scopes.
  # config.sign_out_all_scopes = true

  # The default HTTP method used to sign out a resource. Default is :delete.
  config.sign_out_via = :delete

  # ==> OmniAuth
  # Add a new OmniAuth provider. Check the wiki for more information on setting
  # up on your models and hooks.

  config.omniauth(
    :entra_id,
    {
      tenant_id:     ENV.fetch('ENTRA_TENANT_ID', nil),
      client_id:     ENV.fetch('ENTRA_CLIENT_ID', nil),
      client_secret: ENV.fetch('ENTRA_CLIENT_SECRET', nil),
      # Uncomment when we move to certificates
      # certificate_path: certificate_path,

      # We set this so the login prompt always goes to the "select
      # account" menu
      authorize_params: {
        prompt: 'select_account'
      },
      strategy_class: Silas::SilasStrategy
    }
  )
end
