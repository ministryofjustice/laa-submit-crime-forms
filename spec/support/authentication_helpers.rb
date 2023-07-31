module AuthenticationHelpers
  def sign_in(provider = nil)
    provider ||= instance_double(Provider, selected_office_code: 'AAA')
    allow(warden).to receive_messages(authenticate!: provider, authenticate: provider)
  end
end
