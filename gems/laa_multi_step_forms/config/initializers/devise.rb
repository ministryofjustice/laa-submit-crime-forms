# frozen_string_literal: true

Devise.setup do |config|
  # Prevent deprecation warning
  # DEPRECATION WARNING: `Rails.application.secrets` is deprecated in favor of `Rails.application.credentials`
  # and will be removed in Rails 7.2.
  config.secret_key = Rails.application.secret_key_base
end
