require 'rails_helper'

RSpec.describe 'User can fill in claim type details', type: :system do
  let(:claim) { Claim.create(office_code: 'AAAA') }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can do green path' do
    visit edit_steps_hearing_details_path(claim.id)

    within '#steps-hearing_details-form-first-hearing-date' do
      fill_in 'Day', with: '20'
      fill_in 'Month', with: '4'
      fill_in 'Year', with: '2023'
    end

    fill_in 'Number of hearing held', with: 2

    select "Aberystwyth Magistrates' Court", from: 'Which court was the hearing held at?'

    find('.govuk-form-group', text: 'Is this court in a designated area of your firm?').choose 'Yes'
    find('.govuk-form-group', text: 'Is this court a youth court?').choose 'No'

    select 'CP03 - Representation order withdrawn', from: 'Hearing outcome'

    select '1 - Offences against the person', from: 'Matter type'

    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(
      first_hearing_date: Date.new(2023, 4, 20),
      number_of_hearing: 2,
      court: "Aberystwyth Magistrates' Court",
      in_area: 'yes',
      youth_count: 'no',
      hearing_outcome: 'CP03',
      matter_type: '1',
    )
  end
end
