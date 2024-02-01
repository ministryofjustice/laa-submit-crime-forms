# frozen_string_literal: true

module PriorAuthority
  module StepHelpers
    # rubocop:disable Metrics/CyclomaticComplexity
    def fill_in_until_step(step, prison_law: 'No', court_type: "Magistrate's court")
      fill_in_prison_law_and_authority_value(prison_law)

      return if step == :ufn

      fill_in_ufn

      return if step.in?(%i[your_application_progress case_contact])

      fill_in_case_contact

      return if step == :client_detail

      fill_in_client_detail

      return if step == :case_detail

      fill_in_case_detail

      return if step == :hearing_detail

      fill_in_hearing_detail(court_type:)

      return if step.in?(%i[psychiatric_liaison youth_court])

      fill_in_youth_court

      return if step == :primary_quote

      fill_in_primary_quote

      :end
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    def fill_in_prison_law_and_authority_value(prison_law)
      visit provider_saml_omniauth_callback_path
      visit prior_authority_root_path

      click_on 'New application'
      choose prison_law
      click_on 'Save and continue'
      choose 'No'
      click_on 'Save and continue'
    end

    def fill_in_ufn
      fill_in 'What is your unique file number?', with: '111111/123'
      click_on 'Save and continue'
    end

    def fill_in_case_contact
      click_on 'Case contact'
      fill_in 'Full name', with: 'John Doe'
      fill_in 'Email address', with: 'john@does.com'
      fill_in 'Firm name', with: 'LegalCorp Ltd'
      fill_in 'Firm account number', with: 'A12345'
      click_on 'Save and continue'
    end

    def fill_in_client_detail
      fill_in 'First name', with: 'John'
      fill_in 'Last name', with: 'Doe'

      within('.govuk-form-group', text: 'Date of birth') do
        fill_in 'Day', with: '27'
        fill_in 'Month', with: '12'
        fill_in 'Year', with: '2000'
      end

      click_on 'Save and continue'
    end

    def fill_in_case_detail
      fill_in 'What was the main offence', with: 'Supply a controlled drug of Class A - Heroin'

      within('.govuk-form-group', text: 'Date of representation order') do
        fill_in 'Day', with: '27'
        fill_in 'Month', with: '12'
        fill_in 'Year', with: '2023'
      end

      fill_in 'MAAT number', with: '123456'
      within('.govuk-form-group', text: 'Is your client detained?') do
        choose 'No'
      end

      within('.govuk-form-group', text: 'Is this case subject to POCA (Proceeds of Crime Act 2002)?') do
        choose 'Yes'
      end

      click_on 'Save and continue'
    end

    def fill_in_hearing_detail(plea: 'Not guilty', court_type: "Magistrate's court")
      within('.govuk-form-group', text: 'Date of next hearing') do
        dt = Date.tomorrow
        fill_in 'Day', with: dt.day
        fill_in 'Month', with: dt.month
        fill_in 'Year', with: dt.year
      end

      choose plea
      choose court_type
      click_on 'Save and continue'
    end

    def fill_in_youth_court
      within('.govuk-form-group', text: 'Is this a youth court matter') do
        choose 'No'
      end
      click_on 'Save and continue'
    end

    def fill_in_primary_quote
      click_on 'Primary quote'

      fill_in 'Service required', with: 'Forensics'
      fill_in 'Contact full name', with: 'Joe Bloggs'
      fill_in 'Organisation', with: 'LAA'
      fill_in 'Postcode', with: 'CR0 1RE'

      click_on 'Save and come back later'
    end
  end
end

RSpec.configure do |config|
  config.include PriorAuthority::StepHelpers, type: :system
end
