require 'system_helper'

RSpec.describe 'Prior authority applications - add primary quote', :javascript, type: :system do
  before do
    fill_in_until_step(:your_application_progress)
  end

  it 'cannot initially access form' do
    expect(page).to have_content 'Primary quote Cannot start yet'
  end

  context 'when I have not filled the primary quote form in yet' do
    before do
      fill_in_until_step(:primary_quote)
      click_on 'Primary quote'
    end

    it 'shows the empty selected file table' do
      expect(page.find('.moj-multi-file__uploaded-files')).to have_content 'Selected file'
      expect(page.find('.moj-multi-file__uploaded-files')).to have_content 'File name'
    end
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

    it 'pre-populates selected file' do
      click_on 'Save and continue'
      click_on 'Back'
      expect(page).to have_content 'test.png'
    end

    it 'updates selected file table' do
      click_on 'Save and continue'
      click_on 'Back'
      page.attach_file(file_fixture('test_2.png')) do
        page.find('.govuk-file-upload').click
      end
      expect(page.find('.moj-multi-file-upload__filename')).to have_content 'test_2.png'
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

  describe 'client-side size validation' do
    around do |example|
      default_size = ENV.fetch('PA_MAX_UPLOAD_SIZE_BYTES')
      ENV['PA_MAX_UPLOAD_SIZE_BYTES'] = (Rails.root.join('spec/fixtures/files/test_2.png').open.size - 1).to_s
      example.run
      ENV['PA_MAX_UPLOAD_SIZE_BYTES'] = default_size
    end

    it 'validates file size client side before attempting upload and save' do
      fill_in_until_step(:primary_quote)
      click_on 'Primary quote'

      page.attach_file(file_fixture('test_2.png')) do
        page.find('.govuk-file-upload').click
      end

      click_on 'Save and continue'
      expect(page).to have_content(/The selected file must be smaller than \d+MB/i)
    end
  end
end
