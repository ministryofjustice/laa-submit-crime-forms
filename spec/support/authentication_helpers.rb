module AuthenticationHelpers
  # allow the provider to be defined in the spec with a `let`. This allows
  # additional functionality/attributes to be set without affecting auth
  # or having to worry about order of precedence
  def self.included(base)
    base.let(:auth_user) do
      if defined? provider
        provider
      elsif defined? caseworker
        caseworker
      else
        create(:user)
        # instance_double(User, id: SecureRandom.uuid, selected_office_code: 'AAA')
      end
    end
  end

  def sign_in
    allow(warden).to receive_messages(authenticate!: auth_user, authenticate: auth_user)
  end
end
