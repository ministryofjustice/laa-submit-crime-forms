FactoryBot.define do
  factory :prior_authority_application do
    provider { Provider.find_by(uid: 'test-user') || create(:provider) }
    office_code { '1A123B' }

    # these are to add randomness to the TestData generation process
    transient do
      date { Date.new(2023, 4, 12) }
      service_type_cost_type { :per_hour }
      service_type_options do
        services = PriorAuthority::QuoteServices::VALUES.select do |service_type|
          rule = PriorAuthority::ServiceTypeRule.build(service_type)
          # skip cour order and post mortem as they add too much complexity
          rule.cost_type.in?([service_type_cost_type, :variable]) && !rule.court_order_relevant && !rule.post_mortem_relevant
        end
        services.map(&:value) + ['custom']
      end
      primary_quotes { build_list(:quote, 1, :primary, service_type_cost_type) }
    end

    PriorAuthorityApplication.states.each_key do |state|
      trait :"as_#{state}" do
        state { state }
      end
    end

    trait :with_firm_and_solicitor do
      firm_office factory: %i[firm_office valid_pa]
      solicitor factory: %i[solicitor full_pa]
    end

    trait :with_defendant do
      defendant factory: %i[defendant valid_paa], strategy: :build
    end

    trait :with_client_details do
      with_defendant
    end

    trait :with_case_details do
      main_offence_id { 'robbery' }
      rep_order_date { date - rand(10..365) }
      client_detained { false }
      subject_to_poca { false }
      next_hearing_date { date + rand(10..365) }
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
      ufn { "#{date.strftime('%d%m%y')}/001" }
      with_firm_and_solicitor
      next_hearing { false }
      viewed_steps { %w[ufn case_contact client_detail next_hearing] }
      after(:create) do |paa, _a|
        create(:defendant, :valid_paa, defendable_id: paa.id, defendable_type: paa.class.to_s)
      end
    end

    trait :with_primary_quote do
      with_firm_and_solicitor
      with_defendant
      with_case_details
      with_psychiatric_liaison
      primary_quote factory: %i[quote primary], strategy: :build
      ufn { "#{date.strftime('%d%m%y')}/001" }
      service_type { 'meteorologist' }
      prior_authority_granted { true }
      viewed_steps { %w[ufn case_contact client_detail case_hearing primary_quote primary_quote_summary] }
      after(:create) do |paa, _a|
        create(:defendant, :valid_paa, defendable_id: paa.id, defendable_type: paa.class.to_s)
      end
    end

    trait :with_primary_quote_per_item do
      with_primary_quote
      primary_quote factory: %i[quote primary_per_item], strategy: :build
    end

    trait :full do
      with_firm_and_solicitor
      with_defendant
      with_psychiatric_liaison
      ufn { "#{date.strftime('%d%m%y')}/123" }
      defendant factory: %i[defendant valid_paa], strategy: :build
      prison_law { true }
      reason_why { 'something' }
      main_offence_id { 'something' }
      client_detained { true }
      prison_id { 'something' }
      subject_to_poca { true }
      next_hearing_date { 1.day.from_now }
      plea { 'guilty' }
      youth_court { 'something' }
      next_hearing { true }
      supporting_documents { build_list(:supporting_document, 2) }
      prior_authority_granted { false }
      no_alternative_quote_reason { 'a reason' }
      alternative_quotes_still_to_add { false }
      service_type { 'pathologist_report' }
      custom_service_name { nil }
      viewed_steps do
        %w[ufn case_contact client_detail case_detail next_hearing primary_quote primary_quote_summary alternative_quotes
           reason_why]
      end

      after(:build) do |paa|
        build(:quote, :primary, prior_authority_application_id: paa.id)
        build(:quote, :alternative, document: nil, prior_authority_application_id: paa.id)
      end

      after(:create) do |paa|
        create(:quote, :primary, prior_authority_application_id: paa.id)
        create(:quote, :alternative, document: nil, prior_authority_application_id: paa.id)
      end
    end

    trait :sent_back_for_incorrect_info do
      state { 'sent_back' }
      resubmission_deadline { 14.days.from_now }
      resubmission_requested { DateTime.current }
      app_store_updated_at { DateTime.current }

      transient do
        information_requested { 'Please update the case details' }
      end

      after(:create) do |paa, evaluator|
        create(:incorrect_information,
               prior_authority_application_id: paa.id,
               information_requested: evaluator.information_requested)
      end
    end

    trait :with_further_information_request do
      further_informations { [build(:further_information)] }
      state { 'sent_back' }
      app_store_updated_at { 1.minute.ago }
      resubmission_deadline { 14.days.from_now }
      resubmission_requested { DateTime.current }
    end

    trait :with_further_information_supplied do
      after(:create) do |paa|
        create(:further_information, :with_response, :with_supporting_documents, submission: paa)
      end
    end

    trait :with_corrections do
      after(:create) do |paa|
        create(:incorrect_information, :with_edits, prior_authority_application_id: paa.id)
      end
    end

    trait :with_complete_non_prison_law do
      prison_law { false }
      ufn { "#{date.strftime('%d%m%y')}/123" }
      with_firm_and_solicitor
      with_defendant

      # case details
      main_offence_id { I18n.t('prior_authority.offences').to_a.sample.first }
      rep_order_date { 1.year.ago.to_date }
      client_detained { false }
      subject_to_poca { true }

      # hearing details
      next_hearing { true }
      next_hearing_date { 1.day.from_now }
      plea { 'not_guilty' }
      court_type { 'magistrates_court' }
      youth_court { false }

      # quotes
      service_type { service_type_options.sample }
      custom_service_name { service_type == 'custom' ? Faker::ProgrammingLanguage.name : nil }
      primary_quote { quotes.first }
      supporting_documents { build_list(:supporting_document, 2) }
      quotes { primary_quotes }
      prior_authority_granted { false }
      no_alternative_quote_reason { 'a reason' }
      alternative_quotes_still_to_add { false }

      further_informations { [build(:further_information, :with_response)] }
      reason_why { 'something' }
      viewed_steps do
        %w[ufn case_contact client_detail case_detail next_hearing primary_quote primary_quote_summary alternative_quotes
           reason_why]
      end
    end

    trait :with_complete_prison_law do
      prison_law { true }
      ufn { "#{date.strftime('%d%m%y')}/123" }
      with_firm_and_solicitor
      with_defendant

      # next hearing details
      next_hearing { true }
      next_hearing_date { 1.day.from_now }

      # quotes
      service_type { service_type_options.sample }
      custom_service_name { service_type == 'custom' ? Faker::ProgrammingLanguage.name : nil }
      primary_quote { quotes.first }
      supporting_documents { build_list(:supporting_document, 2) }
      quotes { primary_quotes }
      prior_authority_granted { false }
      no_alternative_quote_reason { 'a reason' }
      alternative_quotes_still_to_add { false }

      further_informations { [build(:further_information, :with_response)] }
      reason_why { 'something' }
    end

    trait :with_all_tasks_completed do
      prison_law { true }
      ufn { "#{date.strftime('%d%m%y')}/123" }
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
      viewed_steps do
        %w[ufn case_contact client_detail case_detail next_hearing primary_quote primary_quote_summary alternative_quotes
           reason_why]
      end
      after(:create) do |paa, _a|
        create(:defendant, :valid_paa, defendable_id: paa.id, defendable_type: paa.class.to_s)
      end
    end

    trait :with_alternative_quotes do
      transient do
        quote_count { 2 }
        alternative_quotes { build_list(:quote, quote_count, :alternative, service_type_cost_type) }
      end

      quotes { primary_quotes + alternative_quotes }
    end

    trait :with_ufn do
      ufn { "#{date.strftime('%d%m%y')}/001" }
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

    trait :randomised do
      ufn do
        random_date = Faker::Date.between(from: 10.years.ago, to: 1.day.ago)
        "#{random_date.strftime('%d%m%y')}/#{SecureRandom.rand(1000).to_s.rjust(3, '0')}"
      end
      firm_office factory: %i[firm_office valid_pa randomised]
    end
  end
end
