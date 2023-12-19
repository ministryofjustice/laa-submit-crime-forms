module WardenHooks
  # On sign-in, record last_auth_at and set the user's name and email
  # using the details in the OmniAuth auth_hash.
  #
  # Additionally, if the user is pending activation, set the first_auth_at
  # and the auth_uid.
  #
  # This code block is only triggered when the user is explicitly set (with set_user)
  # and during authentication. Retrieving the user from session (:fetch) will not trigger it.

  module AuthUpdateable
    # rubocop:disable Lint/NonLocalExitFromIterator
    Warden::Manager.after_set_user except: :fetch do |user, warden, options|
      # :nocov:
      return unless user && warden.authenticated?(options[:scope])
      # :nocov:

      user.update_from_auth_hash!(warden)
    end
    # rubocop:enable Lint/NonLocalExitFromIterator
  end
end
