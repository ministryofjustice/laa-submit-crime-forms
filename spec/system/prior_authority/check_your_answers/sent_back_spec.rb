require 'system_helper'

RSpec.describe 'Prior authority applications, no prison law - check your answers' do
  before do
    visit provider_saml_omniauth_callback_path
    visit prior_authority_steps_check_answers_path(application)
  end

  let(:application) do
    create(:prior_authority_application, :full, :with_sent_back_status)
  end

  it 'shows the incorrect information details from the caseworker' do
    expect(page)
      .to have_content('Your application needs existing information corrected', count: 1)
      .and have_content('Please correct the following information...', count: 1)
  end
end
