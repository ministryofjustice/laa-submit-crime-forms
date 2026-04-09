require 'system_helper'

RSpec.describe 'Prior authority applications - alternative quote decimal items' do
  let(:application) do
    create(:prior_authority_application, :with_primary_quote_per_item, service_type: 'photocopying')
  end

  before do
    visit provider_entra_id_omniauth_callback_path
    visit prior_authority_steps_start_page_path(application)

    click_on 'Alternative quotes'
    choose 'Yes'
    click_on 'Save and continue'
  end

  it 'shows an item-aware validation instead of crashing for decimal page counts' do
    fill_in 'First name', with: 'Mrs'
    fill_in 'Last name', with: 'Expert'
    fill_in 'Organisation', with: 'ExpertiseCo'
    fill_in 'Postcode', with: 'SW1 1AA'
    fill_in 'Number of pages', with: '205.70'
    fill_in 'What is the cost per page?', with: '3'

    click_on 'Save and continue'

    expect(page)
      .to have_content('There is a problem')
      .and have_content('The number of pages must be a number, like 25')
  end
end
