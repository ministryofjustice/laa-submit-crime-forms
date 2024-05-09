module AuthenticationHelpers
  # allow the provider to be defined in the spec with a `let`. This allows
  # additional functionality/attributes to be set without affecting auth
  # or having to worry about order of precedence
  def self.included(base)
    base.let(:auth_provider) do
      if defined? provider
        provider
      else
        create(:provider)
      end
    end
  end

  def sign_in
    allow(warden).to receive_messages(authenticate!: auth_provider, authenticate: auth_provider)
  end
end
