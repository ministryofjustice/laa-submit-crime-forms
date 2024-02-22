# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
module PriorAuthority
  module StepHelpers
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/AbcSize
    def fill_in_until_step(step, prison_law: 'No', client_detained: 'No', court_type: "Magistrates' court")
      fill_in_prison_law_and_authority_value(prison_law)

      return if step == :ufn

      fill_in_ufn

      return if step.in?(%i[your_application_progress case_contact])

      click_on 'Case contact'
      fill_in_case_contact

      return if step == :client_detail

      click_on 'Client details'
      fill_in_client_detail

      return if step == :case_detail

      click_on 'Case and hearing details'
      if prison_law == 'Yes'
        fill_in_next_hearing
      else
        fill_in_case_detail(client_detained:)

        return if step == :hearing_detail

        fill_in_hearing_detail(court_type:)

        return if step.in?(%i[psychiatric_liaison youth_court])

        fill_in_youth_court
      end

      return if step == :primary_quote

      click_on 'Primary quote'
      fill_in_primary_quote

      return if step == :service_cost

      fill_in_service_cost

      return if step.in?(%i[primary_quote_summary travel_cost])

      within('#travel-cost-summary') { click_on 'Change' }
      fill_in_travel_cost(prison_law:, client_detained:)
      click_on 'Save and continue'

      return if step == :alternative_quote_question

      click_on 'Alternative quotes'
      fill_in_alternative_quote_question

      return if step == :add_alternative_quote

      fill_in_alternative_quote

      return if step == :reason_for_prior_authority

      click_on 'Reason for prior authority'
      fill_in_reason_for_prior_authority

      return if step == :submit_application

      :end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/AbcSize

    def fill_in_prison_law_and_authority_value(prison_law)
      visit provider_saml_omniauth_callback_path
      visit prior_authority_root_path

      click_on 'Make a new application'
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

    def fill_in_case_detail(client_detained: 'No', client_detained_prison: '')
      fill_in 'What was the main offence', with: 'Supply a controlled drug of Class A - Heroin'

      within('.govuk-form-group', text: 'Date of representation order') do
        fill_in 'Day', with: '27'
        fill_in 'Month', with: '12'
        fill_in 'Year', with: '2023'
      end

      fill_in 'MAAT number', with: '123456'
      within('.govuk-form-group', text: 'Is your client detained?') do
        choose client_detained
        fill_in 'Where is your client detained?', with: client_detained_prison if client_detained == 'Yes'
      end

      within('.govuk-form-group', text: 'Is this case subject to POCA (Proceeds of Crime Act 2002)?') do
        choose 'Yes'
      end

      click_on 'Save and continue'
    end

    def fill_in_next_hearing
      choose 'No'
      click_on 'Save and continue'
    end

    def fill_in_hearing_detail(plea: 'Not guilty', court_type: "Magistrates' court")
      choose 'Yes'

      within('.govuk-form-group', text: 'Date of next hearing', match: :first) do
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

    def fill_in_primary_quote(service_type: 'Meteorologist')
      # Note that if Javascript is enabled for the current test, this will
      # be hidden
      select service_type, from: 'Service required'

      fill_in 'Contact full name', with: 'Joe Bloggs'
      fill_in 'Organisation', with: 'LAA'
      fill_in 'Postcode', with: 'CR0 1RE'

      attach_file(file_fixture('test.png'))

      click_on 'Save and continue'
    end

    def fill_in_travel_cost(prison_law: 'No', client_detained: 'No')
      if prison_law == 'No' && client_detained == 'No'
        fill_in 'Why are there travel costs if your client is not detained?', with: 'Client lives in Wales'
      end

      fill_in 'Hours', with: 0
      fill_in 'Minutes', with: 30
      fill_in 'Hourly cost', with: 3.21
      click_on 'Save and continue'
    end

    def fill_in_service_cost(cost_type: :variable)
      choose 'Yes'
      choose 'Charged per item' if cost_type == :variable

      if cost_type == :per_hour
        fill_in 'Hours', with: '1'
        fill_in 'Minutes', with: '0'
        fill_in 'Hourly cost', with: '100'
      else
        fill_in 'Number of items', with: '5'
        fill_in 'What is the cost per item?', with: '1.23'
      end

      click_on 'Save and continue'
    end

    def fill_in_alternative_quote_question
      choose 'Yes'

      click_on 'Save and continue'
    end

    def fill_in_alternative_quote
      fill_in 'Contact full name', with: 'Jim Bob'
      fill_in 'Organisation', with: 'Experts Inc.'
      fill_in 'Postcode', with: 'SW1A 1AA'

      choose 'Charged per item'
      fill_in 'Number of items', with: '1'
      fill_in 'What is the cost per item?', with: '100'
      fill_in 'prior_authority_steps_alternative_quotes_detail_form_travel_time_1', with: '1'
      fill_in 'prior_authority_steps_alternative_quotes_detail_form_travel_time_2', with: '0'
      fill_in 'What is the hourly cost?', with: '50'
      fill_in 'Total additional costs', with: '5'

      click_on 'Save and continue'

      within('.govuk-form-group', text: 'Do you want to add an additional quote?') do
        choose 'No'
      end
      click_on 'Save and continue'
    end

    def fill_in_reason_for_prior_authority
      fill_in 'Why is prior authority required?', with: 'Required because...'

      click_on 'Save and continue'
    end
  end
end
# rubocop:enable Metrics/ModuleLength

RSpec.configure do |config|
  config.include PriorAuthority::StepHelpers, type: :system
end
