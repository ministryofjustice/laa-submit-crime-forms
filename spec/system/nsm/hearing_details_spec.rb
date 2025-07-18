require 'rails_helper'

RSpec.describe 'User can fill in claim type details', type: :system do
  let(:claim) { create(:claim) }

  before do
    visit provider_entra_id_omniauth_callback_path
  end

  it 'can do green path' do
    visit edit_nsm_steps_hearing_details_path(claim.id)

    within '#steps-hearing_details-form-first-hearing-date' do
      fill_in 'Day', with: '20'
      fill_in 'Month', with: '4'
      fill_in 'Year', with: '2023'
    end

    fill_in 'How many hearings were held for this case?', with: 2

    select 'Aberconwy PSD - C3237', from: 'Which court was the first case hearing heard at?'

    find('.govuk-form-group', text: 'Is this court a youth court?').choose 'No'

    select 'CP03 - Representation order withdrawn', from: 'Hearing outcome'

    select '1 - Offences against the person', from: 'Matter type'

    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(
      first_hearing_date: Date.new(2023, 4, 20),
      number_of_hearing: 2,
      court: 'Aberconwy PSD - C3237',
      youth_court: 'no',
      hearing_outcome: 'CP03',
      matter_type: '1',
    )
  end
end
