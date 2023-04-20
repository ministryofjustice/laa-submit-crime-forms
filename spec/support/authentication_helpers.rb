module AuthenticationHelpers
  def sign_in(provider = nil)
    provider ||= instance_double('Provider', selected_office_code: 'AAA')
    allow(warden).to receive(:authenticate!).and_return(provider)
    allow(warden).to receive(:authenticate).and_return(provider)
  end
end
