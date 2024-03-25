FactoryBot.define do
  factory :prior_authority_application do
    provider { Provider.find_by(uid: 'test-user') || create(:provider) }
    office_code { '1A123B' }
    laa_reference { 'LAA-n4AohV' }

    trait :with_firm_and_solicitor do
      firm_office factory: %i[firm_office valid]
      solicitor factory: %i[solicitor full]
    end

    trait :with_defendant do
      defendant factory: %i[defendant valid_paa], strategy: :build
    end

    trait :with_client_details do
      with_defendant
    end

    trait :with_case_details do
      main_offence_id { 'jaywalking' }
      rep_order_date { 1.year.ago }
      client_detained { false }
      subject_to_poca { false }
      next_hearing_date { 1.year.from_now }
      plea { 'guilty' }
    end

    trait :with_psychiatric_liaison do
      court_type { 'central_criminal_court' }
      youth_court { nil }
      psychiatric_liaison { false }
      psychiatric_liaison_reason_not { 'whatever you like' }
    end

    trait :with_youth_court do
      court_type { 'magistrates_court' }
      youth_court { true }
      psychiatric_liaison { nil }
      psychiatric_liaison_reason_not { nil }
    end

    trait :about_request_enabled do
      prison_law { true }
      ufn { '120423/001' }
      with_firm_and_solicitor
      next_hearing { false }
      after(:create) do |paa, _a|
        create(:defendant, :valid_paa, defendable_id: paa.id, defendable_type: paa.class.to_s)
        paa.navigation_stack << "/prior-authority/applications/#{paa.id}/steps/ufn"
        paa.navigation_stack << "/prior-authority/applications/#{paa.id}/steps/case_contact"
        paa.navigation_stack << "/prior-authority/applications/#{paa.id}/steps/client_detail"
        paa.navigation_stack << "/prior-authority/applications/#{paa.id}/steps/next_hearing"
        paa.save
      end
    end

    trait :with_primary_quote do
      with_firm_and_solicitor
      with_defendant
      with_case_details
      with_psychiatric_liaison
      primary_quote factory: %i[quote primary], strategy: :build
      ufn { '120423/001' }
      service_type { 'meteorologist' }
      prior_authority_granted { true }
      after(:create) do |paa, _a|
        create(:defendant, :valid_paa, defendable_id: paa.id, defendable_type: paa.class.to_s)
        paa.navigation_stack << "/prior-authority/applications/#{paa.id}/steps/ufn"
        paa.navigation_stack << "/prior-authority/applications/#{paa.id}/steps/case_contact"
        paa.navigation_stack << "/prior-authority/applications/#{paa.id}/steps/client_detail"
        paa.navigation_stack << "/prior-authority/applications/#{paa.id}/steps/case_detail"
        paa.navigation_stack << "/prior-authority/applications/#{paa.id}/steps/primary_quote"
        paa.navigation_stack << "/prior-authority/applications/#{paa.id}/steps/primary_quote_summary"
        paa.save
      end
    end

    trait :with_primary_quote_per_item do
      with_primary_quote
      primary_quote factory: %i[quote primary_per_item], strategy: :build
    end

    trait :with_confirmations do
      confirm_excluding_vat { true }
      confirm_travel_expenditure { true }
    end

    trait :full do
      with_firm_and_solicitor
      with_defendant
      with_psychiatric_liaison
      ufn { '120423/123' }
      defendant factory: %i[defendant valid_paa], strategy: :build
      prison_law { true }
      reason_why { 'something' }
      main_offence_id { 'something' }
      client_detained { true }
      prison_id { 'something' }
      subject_to_poca { true }
      next_hearing_date { 1.day.from_now }
      plea { 'something' }
      youth_court { 'something' }
      next_hearing { true }
      supporting_documents { build_list(:supporting_document, 2) }
      quotes { [build(:quote, :primary), build(:quote, :alternative, document: nil)] }
      prior_authority_granted { false }
      no_alternative_quote_reason { 'a reason' }
      service_type { 'pathologist_report' }
      custom_service_name { nil }
    end

    trait :with_sent_back_status do
      status { 'sent_back' }
      further_information_explanation { 'Please provide more evidence to support the service costs...' }
      incorrect_information_explanation { 'Please correct the following information...' }
      resubmission_deadline { 14.days.from_now }
    end

    trait :with_complete_non_prison_law do
      prison_law { false }
      ufn { '120423/123' }
      with_firm_and_solicitor
      with_defendant

      # case details
      main_offence_id { 'jaywalking' }
      rep_order_date { 1.year.ago.to_date }
      client_detained { false }
      subject_to_poca { true }

      # hearing details
      next_hearing_date { 1.day.from_now }
      plea { 'not_guilty' }
      court_type { 'magistrates_court' }
      youth_court { false }

      # quotes
      service_type { 'telecommunications_expert' }
      primary_quote factory: %i[quote primary], strategy: :build
      supporting_documents { build_list(:supporting_document, 2) }
      quotes { build_list(:quote, 1, :primary) }
      prior_authority_granted { false }
      no_alternative_quote_reason { 'a reason' }

      reason_why { 'something' }
    end

    trait :with_complete_prison_law do
      prison_law { true }
      ufn { '120423/123' }
      with_firm_and_solicitor
      with_defendant

      # next hearing details
      next_hearing { true }
      next_hearing_date { 1.day.from_now }

      # quotes
      service_type { 'telecommunications_expert' }
      primary_quote factory: %i[quote primary], strategy: :build
      supporting_documents { build_list(:supporting_document, 2) }
      quotes { build_list(:quote, 1, :primary) }
      prior_authority_granted { false }
      no_alternative_quote_reason { 'a reason' }

      reason_why { 'something' }
    end

    trait :with_all_tasks_completed do
      prison_law { true }
      ufn { '120423/123' }
      with_firm_and_solicitor
      with_defendant

      # next hearing details
      next_hearing { true }
      next_hearing_date { 1.day.from_now }

      # quotes
      service_type { 'telecommunications_expert' }
      primary_quote factory: %i[quote primary], strategy: :build
      supporting_documents { build_list(:supporting_document, 2) }
      prior_authority_granted { false }
      no_alternative_quote_reason { 'a reason' }
      alternative_quotes_still_to_add { false }

      reason_why { 'something' }

      after(:create) do |paa, _a|
        create(:defendant, :valid_paa, defendable_id: paa.id, defendable_type: paa.class.to_s)
        paa.navigation_stack << "/prior-authority/applications/#{paa.id}/steps/ufn"
        paa.navigation_stack << "/prior-authority/applications/#{paa.id}/steps/case_contact"
        paa.navigation_stack << "/prior-authority/applications/#{paa.id}/steps/client_detail"
        paa.navigation_stack << "/prior-authority/applications/#{paa.id}/steps/case_detail"
        paa.navigation_stack << "/prior-authority/applications/#{paa.id}/steps/next_hearing"
        paa.navigation_stack << "/prior-authority/applications/#{paa.id}/steps/primary_quote"
        paa.navigation_stack << "/prior-authority/applications/#{paa.id}/steps/primary_quote_summary"
        paa.navigation_stack << "/prior-authority/applications/#{paa.id}/steps/alternative_quotes"
        paa.navigation_stack << "/prior-authority/applications/#{paa.id}/steps/reason_why"
        paa.save
      end
    end

    trait :with_alternative_quotes do
      quotes { build_list(:quote, 2, :alternative) }
    end

    trait :with_ufn do
      ufn { '120423/001' }
    end

    trait :with_created_alternative_quote do
      after(:create) do |paa|
        create(:quote, :alternative, :with_additional_cost, prior_authority_application_id: paa.id)
      end
    end

    trait :with_created_alternative_quotes do
      after(:create) do |paa|
        create(:quote, :alternative, :with_additional_cost, prior_authority_application_id: paa.id)
        create(:quote, :alternative, :cost_per_item, :with_additional_cost, prior_authority_application_id: paa.id)
      end
    end

    trait :with_created_primary_quote do
      after(:create) do |paa|
        create(:defendant, :valid_paa, defendable_id: paa.id, defendable_type: paa.class.to_s)
        create(:quote, :primary, prior_authority_application_id: paa.id)
      end
    end

    trait :with_additional_costs do
      after(:create) do |paa|
        create(:additional_cost, :per_item, prior_authority_application_id: paa.id)
        create(:additional_cost, :per_hour, prior_authority_application_id: paa.id)
      end
    end
  end
end
