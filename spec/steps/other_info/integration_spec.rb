require 'rails_helper'

RSpec.describe 'User can fill in other relevent information', type: :system do
  let(:claim) do
    Claim.create(office_code: 'AAAA', defendants: [Defendant.new(main: true, full_name: 'Nigel', maat: '123')],
                 plea: PleaOptions.values)
  end

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can do green path' do
    visit edit_steps_other_info_path(claim.id)

    fill_in 'For example, justification for the time spent on the case, or for any uplift claimed',
            with: 'any other relevent information'
    find('.govuk-form-group', text: 'Did the proceedings conclude over 3 months ago?').choose 'Yes'
    fill_in 'Tell us why you did not make this claim within 3 months of the conclusion of the proceedings',
            with: 'conclusion'
    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(
      other_info: 'any other relevent information',
      concluded: 'yes',
      conclusion: 'conclusion'
    )
  end
end
