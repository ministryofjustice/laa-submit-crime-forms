FactoryBot.define do
  factory :claim do
    submitter { Provider.find_by(uid: 'test-user') || create(:provider) }
    office_code { '1A123B' }
    laa_reference { 'LAA-n4AohV' }

    transient do
      date { Date.new(2023, 4, 12) }
      work_items_count { 0 }
      disbursements_count { 0 }
    end

    trait :build_associates do
      work_items do
        uplift_enabled = reasons_for_claim.include?(ReasonForClaim::ENHANCED_RATES_CLAIMED.to_s)
        Array.new(work_items_count) do
          completed_on = date - rand(40)
          has_uplift = [false, false, uplift_enabled].sample # max 1/3 of entries
          args = [:work_item, :valid]
          args << :with_uplift if has_uplift
          build(*args, completed_on:)
        end
      end

      disbursements do
        Array.new(disbursements_count) do
          disbursement_date = date - rand(40)
          type = rand > 0.2 ? :valid : :valid_other
          apply_vat = rand > 0.5 ? 'true' : 'false'

          build(:disbursement, type, disbursement_date:, apply_vat:)
        end
      end

      has_disbursements { disbursements_count.zero? ? 'no' : 'yes' }
    end

    trait :complete do
      assessment_comment { 'this is an assessment' }
      claim_details
      firm_details
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
      one_cost
      is_other_info { 'no' }
      concluded { 'no' }
      signatory_name { Faker::Name.name }
    end

    trait :case_type_magistrates do
      ufn { "#{date.strftime('%d%m%y')}/001" }
      claim_type { 'non_standard_magistrate' }
      rep_order_date { date.strftime('%Y-%m-%d') }
    end

    trait :case_type_breach do
      ufn { "#{date.strftime('%d%m%y')}/002" }
      claim_type { 'breach_of_injunction' }
      cntp_order { "CNTP#{rand(10_000)}" }
      cntp_date { date.strftime('%Y-%m-%d') }
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

    trait :case_details do
      main_offence { MainOffence.all.sample.name }
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
      in_area { 'yes' }
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
    end

    trait :claim_details_no do
      supplemental_claim { 'no' }
      preparation_time { 'no' }
      time_spent { nil }
      work_before { 'no' }
      work_before_date { nil }
      work_after { 'no' }
      work_after_date { nil }
    end

    trait :letters_calls do
      letters { 2 }
      calls { 3 }

      navigation_stack { |claim| ["/non-standard-magistrates/applications/#{claim.id}/steps/letters_calls"] }

      after(:build) do |claim, _context|
        claim.navigation_stack << "/non-standard-magistrates/applications/#{claim.id}/steps/letters_calls"
      end
    end

    trait :one_work_item do
      work_items { [build(:work_item, :valid)] }
    end

    trait :uplifted_work_item do
      with_enhanced_rates
      work_items { [build(:work_item, :with_uplift)] }
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

    trait :one_cost do
      cost_totals { [build(:cost_total, :travel_and_waiting)] }
    end

    trait :completed_status do
      status { :submitted }
    end

    trait :granted_status do
      status { :granted }
    end

    trait :part_granted_status do
      status { :part_grant }
    end

    trait :review_status do
      status { :review }
    end

    trait :further_info_status do
      status { :further_info }
    end

    trait :provider_requested_status do
      status { :provider_requested }
    end

    trait :rejected_status do
      status { :rejected }
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
  end
end
