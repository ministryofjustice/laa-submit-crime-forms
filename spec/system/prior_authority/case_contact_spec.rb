require 'system_helper'

RSpec.describe 'Prior authority applications - add case contact' do
  before do
    fill_in_until_step(:case_contact)
  end

  it 'allows contact detail creation' do
    expect(page).to have_content 'Case contactNot started'

    click_on 'Case contact'
    fill_in 'First name', with: 'John'
    fill_in 'Last name', with: 'Doe'
    fill_in 'Email address', with: 'john@does.com'
    fill_in 'Firm name', with: 'LegalCorp Ltd'
    fill_in 'Firm account number', with: 'A12345'
    click_on 'Save and continue'

    expect(page).to have_content 'Case contactCompleted'
  end

  it 'does validations' do
    expect(page).to have_content 'Case contactNot started'

    click_on 'Case contact'
    click_on 'Save and continue'

    expect(page).to have_content "Enter the contact's first name"
  end

  it 'allows save and come back later' do
    expect(page).to have_content 'Case contactNot started'

    click_on 'Case contact'
    click_on 'Save and come back later'

    expect(page).to have_title 'Your applications'
  end

  context 'when the screen has already been filled in' do
    before do
      click_on 'Case contact'
      fill_in_case_contact
    end

    it 'allows contact detail updating' do
      click_on 'Case contact'
      fill_in 'First name', with: 'Jane'
      click_on 'Save and continue'

      expect(page).to have_content 'Case contactCompleted'
    end

    it 'allows firm detail updating' do
      click_on 'Case contact'
      fill_in 'Firm account number', with: 'A12345'
      click_on 'Save and continue'

      expect(page).to have_content 'Case contactCompleted'
    end
  end
end
