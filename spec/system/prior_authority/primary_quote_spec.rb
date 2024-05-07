require 'system_helper'

RSpec.describe 'Prior authority applications - add primary quote', :javascript, type: :system do
  before do
    fill_in_until_step(:your_application_progress)
  end

  it 'cannot initially access form' do
    expect(page).to have_content 'Primary quote Cannot start yet'
  end

  context 'when I fill in a primary quote' do
    before do
      fill_in_until_step(:primary_quote)
      click_on 'Primary quote'
      expect(page).to have_title 'Primary quote'

      fill_in 'Service required', with: 'Custom Forensics'
      fill_in 'First name', with: 'Joe'
      fill_in 'Last name', with: 'Bloggs'
      fill_in 'Organisation', with: 'LAA'
      fill_in 'Town', with: 'Royston Vasey'
      fill_in 'Postcode', with: 'CR0 1RE'
      page.attach_file(file_fixture('test.png')) do
        page.find('.govuk-file-upload').click
      end
    end

    it 'allows primary quote creation' do
      click_on 'Save and continue'
      expect(page).to have_content 'Service cost'
    end

    it 'pre-populates the text field with a custom service name' do
      click_on 'Save and continue'
      click_on 'Back'
      expect(page).to have_field 'Service required', with: 'Custom Forensics'
    end
  end

  it 'validates primary quote form fields' do
    fill_in_until_step(:primary_quote)
    click_on 'Primary quote'

    page.attach_file(file_fixture('test.png')) do
      page.find('.govuk-file-upload').click
    end

    click_on 'Save and continue'
    expect(page).to have_content 'Enter the service required'
    expect(page).to have_content "Enter the service provider's first name"
    expect(page).to have_content "Enter the service provider's last name"
    expect(page).to have_content 'Enter the organisation name'
    expect(page).to have_content 'Enter the postcode'
  end

  it 'allows save and come back later' do
    fill_in_until_step(:primary_quote)
    click_on 'Primary quote'

    click_on 'Save and come back later'
    expect(page).to have_content 'Your applications'
  end
end
