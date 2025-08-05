FactoryBot.define do
  factory :claim do
    submitter { Provider.find_by(uid: 'test-user') || create(:provider) }
    office_code { '1A123B' }

    transient do
      date { Date.new(2023, 4, 12) }
      work_items_count { 0 }
      work_items_adjusted { false }
      disbursements_count { 0 }
      disbursements_adjusted { false }
    end

    trait :build_associates do
      work_items do
        uplift_enabled = reasons_for_claim.include?(ReasonForClaim::ENHANCED_RATES_CLAIMED.to_s)
        Array.new(work_items_count) do
          completed_on = date - rand(40)
          has_uplift = [false, false, uplift_enabled].sample # max 1/3 of entries
          args = [:work_item, :valid]
          args << :with_uplift if has_uplift
          args << :with_adjustment if work_items_adjusted
          build(*args, completed_on:)
        end
      end

      disbursements do
        Array.new(disbursements_count) do
          disbursement_date = date - rand(40)
          args = [:disbursement, rand > 0.2 ? :valid : :valid_other]
          args << :with_adjustment if disbursements_adjusted
          apply_vat = rand > 0.5 ? 'true' : 'false'

          build(*args, disbursement_date:, apply_vat:)
        end
      end

      has_disbursements { 'no' }
    end

    Claim.states.each_key do |state|
      trait :"as_#{state}" do
        state { state }
      end
    end

    trait :complete do
      claim_details
      full_firm_details
      main_defendant
      case_details
      hearing_details
      with_enhanced_rates
      case_disposal
      letters_calls
      one_work_item
      one_disbursement
      with_evidence
      with_equality
      is_other_info { 'no' }
      concluded { 'no' }
      signatory_name { Faker::Name.name }
      has_disbursements { 'no' }
      include_youth_court_fee { true }
      import_date { Date.new(2025, 1, 1) }
    end

    trait :case_type_magistrates do
      ufn { "#{date.strftime('%d%m%y')}/001" }
      claim_type { 'non_standard_magistrate' }
      rep_order_date { date.strftime('%Y-%m-%d') }
      office_in_undesignated_area { false }
    end

    trait :case_type_breach do
      ufn { "#{date.strftime('%d%m%y')}/002" }
      claim_type { 'breach_of_injunction' }
      cntp_order { "CNTP#{rand(10_000)}" }
      cntp_date { date.strftime('%Y-%m-%d') }
    end

    trait :youth_court_fee_applied do
      claim_type { 'non_standard_magistrate' }
      rep_order_date { Date.new(2024, 12, 6) }
      plea_category { 'category_1a' }
      plea { 'guilty_plea' }
      youth_court { 'yes' }
      include_youth_court_fee { true }
    end

    trait :firm_details do
      firm_office factory: %i[firm_office valid]
      solicitor factory: %i[solicitor valid]
    end

    trait :full_firm_details do
      firm_office factory: %i[firm_office full]
      solicitor factory: %i[solicitor full]
    end

    trait :main_defendant do
      defendants { [build(:defendant, :valid)] }
    end

    trait :breach_defendant do
      defendants { [build(:defendant, :partial)] }
    end

    trait :with_named_defendant do
      defendants { [build(:defendant, :valid_nsm, first_name: 'Jim', last_name: 'Bob')] }
    end

    trait :case_details do
      main_offence { MainOffence.all.sample.name }
      main_offence_type { 'summary_only' }
      main_offence_date { Date.yesterday }

      assigned_counsel { 'no' }
      unassigned_counsel { 'no' }
      agent_instructed { 'no' }
      remitted_to_magistrate { 'no' }
    end

    trait :with_remittal do
      remitted_to_magistrate { 'yes' }
      remitted_to_magistrate_date { date - rand(40) }
    end

    trait :hearing_details do
      first_hearing_date { date - rand(40) }
      number_of_hearing { 1 }
      youth_court { 'no' }
      court { 'A Court' }
      hearing_outcome { OutcomeCode.all.sample.id }
      matter_type { '1' }
    end

    trait :with_enhanced_rates do
      reasons_for_claim { [ReasonForClaim::ENHANCED_RATES_CLAIMED.to_s] }
    end

    trait :with_rep_order_withdrawn do
      reasons_for_claim { [ReasonForClaim::REPRESENTATION_ORDER_WITHDRAWN.to_s] }
    end

    trait :with_extradition do
      reasons_for_claim { [ReasonForClaim::EXTRADITION.to_s] }
    end

    trait :with_assigned_council do
      assigned_counsel { 'yes' }
    end

    trait :case_disposal do
      plea { PleaOptions.values.reject(&:requires_date_field?).sample.to_s }
      plea_category { PleaOptions.new(plea).category }
    end

    trait :claim_details do
      prosecution_evidence { 1 }
      defence_statement { 10 }
      number_of_witnesses { 2 }
      supplemental_claim { 'yes' }
      preparation_time { 'yes' }
      time_spent { 121 }
      work_before { 'yes' }
      work_before_date { Date.new(2020, 12, 1) }
      work_after { 'yes' }
      work_after_date { Date.new(2020, 1, 1) }
      work_completed_date { Date.new(2020, 1, 2) }
      wasted_costs { 'yes' }
    end

    trait :claim_details_no do
      supplemental_claim { 'no' }
      preparation_time { 'no' }
      time_spent { nil }
      work_before { 'no' }
      work_before_date { nil }
      work_after { 'no' }
      work_after_date { nil }
      wasted_costs { 'no' }
    end

    trait :letters_calls do
      letters { 2 }
      calls { 3 }

      navigation_stack { |claim| ["/non-standard-magistrates/applications/#{claim.id}/steps/letters_calls"] }

      after(:build) do |claim, _context|
        claim.navigation_stack << "/non-standard-magistrates/applications/#{claim.id}/steps/letters_calls"
      end
    end

    trait :adjusted_letters_calls do
      letters_calls
      allowed_letters { letters && (letters / 2) }
      allowed_calls { calls && (calls / 2) }
      letters_adjustment_comment { 'Letters adjusted' }
      calls_adjustment_comment { 'Calls adjusted' }
    end

    trait :letters_calls_uplift do
      letters_uplift { 10 }
      calls_uplift { 20 }
    end

    trait :one_work_item do
      work_items { [build(:work_item, :valid)] }
    end

    trait :uplifted_work_item do
      with_enhanced_rates
      work_items { [build(:work_item, :with_uplift)] }
    end

    trait :two_uplifted_work_items do
      with_enhanced_rates
      after(:create) do |claim|
        create(:work_item, :with_uplift, claim_id: claim.id)
        create(:work_item, :with_uplift, claim_id: claim.id)
      end
    end

    trait :medium_risk_work_item do
      prosecution_evidence { 10 }
      work_items { [build(:work_item, :medium_risk_values)] }
    end

    trait :travel_and_waiting do
      work_items { [build(:work_item, :travel), build(:work_item, :waiting)] }
    end

    trait :one_disbursement do
      disbursements { [build(:disbursement, :valid)] }
    end

    trait :one_other_disbursement do
      disbursements { [build(:disbursement, :valid_other_specific)] }
    end

    trait :mixed_vat_disbursement do
      disbursements { [build(:disbursement, :valid_other), build(:disbursement, :no_vat)] }
    end

    trait :high_cost_disbursement do
      disbursements { [build(:disbursement, :valid_high_cost)] }
    end

    trait :completed_state do
      state { :submitted }
    end

    trait :granted_state do
      state { :granted }
    end

    trait :part_granted_state do
      state { :part_grant }
    end

    trait :sent_back_state do
      state { :sent_back }
    end

    trait :rejected_state do
      state { :rejected }
    end

    trait :updated_at do
      updated_at { Date.new(2023, 12, 1) }
    end

    trait :with_evidence do
      supporting_evidence { [build(:supporting_evidence)] }
    end

    trait :without_equality do
      answer_equality { 'no' }
    end

    trait :with_equality do
      answer_equality { 'yes' }
      disability { 'n' }
      gender { 'm' }
      ethnic_group { '01_white_british' }
    end

    trait :with_assessment_comment do
      assessment_comment { 'this is a comment' }
    end

    trait :randomised do
      ufn do
        random_date = Faker::Date.between(from: 10.years.ago, to: 1.day.ago)
        "#{random_date.strftime('%d%m%y')}/#{SecureRandom.rand(1000).to_s.rjust(3, '0')}"
      end
      firm_office factory: %i[firm_office valid randomised]
    end

    trait :with_further_information_request do
      further_informations { [build(:further_information)] }
      state { 'sent_back' }
      app_store_updated_at { 1.minute.ago }
    end

    trait :with_further_information_supplied do
      further_informations { [build(:further_information, :with_response, :with_supporting_documents)] }
      state { 'sent_back' }
      app_store_updated_at { 1.minute.ago }
    end

    trait :valid_youth_court do
      claim_type { ClaimType::NON_STANDARD_MAGISTRATE.to_s }
      rep_order_date { Constants::YOUTH_COURT_CUTOFF_DATE }
      youth_court { YesNoAnswer::YES.to_s }
      plea_category { PleaCategory::CATEGORY_1A.to_s }
    end
  end
end
