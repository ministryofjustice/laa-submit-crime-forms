module AuthenticationHelpers
  def sign_in(override_provider = nil)
    # allow the provider to be defined in the spec with a `let`. This allows
    # additional functionality/attributes to be set without affecting auth.
    local_provider =
      if defined? provider
        provider
      else
        override_provider || instance_double(Provider, selected_office_code: 'AAA')
      end
    allow(warden).to receive_messages(authenticate!: local_provider, authenticate: local_provider)
  end
end
