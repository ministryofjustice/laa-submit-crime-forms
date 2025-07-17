require 'system_helper'

RSpec.describe 'Prior authority applications - add case contact' do
  before do
    fill_in_until_step(:case_contact)
  end

  it 'allows contact detail creation' do
    expect(page).to have_content 'Case contact Not yet started'

    click_on 'Case contact'
    fill_in 'First name', with: 'John'
    fill_in 'Last name', with: 'Doe'
    fill_in 'Email address', with: 'john@does.com'
    fill_in 'Firm name', with: 'LegalCorp Ltd'
    click_on 'Save and continue'

    first('.govuk-radios__label').click
    click_on 'Save and continue'

    expect(page).to have_content 'Case contact Completed'
  end

  it 'does validations' do
    expect(page).to have_content 'Case contact Not yet started'

    click_on 'Case contact'
    click_on 'Save and continue'

    expect(page).to have_content "Enter the contact's first name"
  end

  it 'validates emails correctly for missing top-level domain' do
    expect(page).to have_content 'Case contact Not yet started'

    click_on 'Case contact'
    fill_in 'First name', with: 'John'
    fill_in 'Last name', with: 'Doe'
    fill_in 'Email address', with: 'john@does'
    fill_in 'Firm name', with: 'LegalCorp Ltd'
    click_on 'Save and continue'

    expect(page).to have_content 'Enter a valid email address'
  end

  it 'validates emails correctly for invalid top-level domain' do
    expect(page).to have_content 'Case contact Not yet started'

    click_on 'Case contact'
    fill_in 'First name', with: 'John'
    fill_in 'Last name', with: 'Doe'
    fill_in 'Email address', with: 'john@does.'
    fill_in 'Firm name', with: 'LegalCorp Ltd'
    click_on 'Save and continue'

    expect(page).to have_content 'Enter a valid email address'
  end

  it 'allows save and come back later' do
    expect(page).to have_content 'Case contact Not yet started'

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
      first('.govuk-radios__label').click
      click_on 'Save and continue'

      expect(page).to have_content 'Case contact Completed'
    end

    it 'allows firm detail updating' do
      click_on 'Case contact'
      fill_in 'Firm name', with: 'LegalCorp 2 Electic Boogaloo'
      click_on 'Save and continue'
      first('.govuk-radios__label').click
      click_on 'Save and continue'

      expect(page).to have_content 'Case contact Completed'
    end
  end

  context 'when the office code has not been set' do
    before do
      Provider.first.update(office_codes: %w[1A123B 1K022G])
      PriorAuthorityApplication.first.update!(office_code: nil)
      allow(ActiveOfficeCodeService).to receive(:call).with(%w[1A123B 1K022G]).and_return(%w[1A123B 1K022G])
    end

    context 'when I have filled in the case contact screen' do
      before do
        click_on 'Case contact'
        fill_in 'First name', with: 'John'
        fill_in 'Last name', with: 'Doe'
        fill_in 'Email address', with: 'john@does.com'
        fill_in 'Firm name', with: 'LegalCorp Ltd'
        click_on 'Save and continue'
      end

      it 'shows me the office code selection screen' do
        expect(page).to have_content 'Which firm office account number is this application for?'
      end

      it 'validates the selection' do
        click_on 'Save and continue'
        expect(page).to have_content 'Select a firm office account number'
      end

      it 'saves the selection' do
        choose '1K022G'
        click_on 'Save and continue'
        expect(page).to have_content 'Case contact Completed'
        expect(PriorAuthorityApplication.first.office_code).to eq '1K022G'
      end

      it 'allows save and come back later' do
        expect(page).to have_content 'Which firm office account number is this application for?'
        click_on 'Save and come back later'

        expect(page).to have_title 'Your applications'
      end
    end
  end
end
