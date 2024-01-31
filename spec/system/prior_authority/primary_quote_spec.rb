require 'system_helper'

RSpec.describe 'Prior authority applications - add primary quote', :javascript, type: :system do
  before do
    fill_in_until_step(:your_application_progress)
  end

  it 'cannot initially access form' do
    expect(page).to have_content 'Primary quote Cannot yet start'
  end

  it 'allows primary quote creation' do
    fill_in_until_step(:primary_quote)
    click_on 'Primary quote'
    expect(page).to have_title 'Primary quote'

    fill_in 'Service required', with: 'Forensics'
    fill_in 'Contact full name', with: 'Joe Bloggs'
    fill_in 'Organisation', with: 'LAA'
    fill_in 'Postcode', with: 'CR0 1RE'

    click_on 'Save and continue'

    expect(page).to have_content 'Primary quote Completed'
  end

  # it 'validates client detail fields' do
  #   expect(page).to have_content 'Client detailsNot started'
  #   click_on 'Client details'

  #   click_on 'Save and continue'
  #   expect(page).to have_content "Enter the client's first name"
  #   expect(page).to have_content "Enter the client's last name"
  #   expect(page).to have_content "Enter the client's date of birth"
  # end

  # it 'allows save and come back later' do
  #   expect(page).to have_content 'Client detailsNot started'
  #   click_on 'Client details'

  #   click_on 'Save and come back later'
  #   expect(page).to have_content 'Client detailsIn progress'
  # end
end
