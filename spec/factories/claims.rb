FactoryBot.define do
  factory :claim do
    id { SecureRandom.uuid }
    submitter { Provider.find_by(uid: 'test-user') || create(:provider) }
    office_code { '1A123B' }

    trait :complete do
      firm_details
      main_defendant
      case_details
      hearing_details
      with_uplift
      case_disposal
      letters_calls
      one_work_item
      one_disbursement
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

    trait :case_details do
      ufn { '20150612/001' }
      main_offence { MainOffence.all.sample.name }
      main_offence_date { Date.yesterday }

      assigned_counsel { 'no' }
      unassigned_counsel { 'no' }
      agent_instructed { 'no' }
      remitted_to_magistrate { 'no' }
    end

    trait :hearing_details do
      first_hearing_date { Date.new(2023, 3, 1) }
      number_of_hearing { 1 }
      youth_count { 'no' }
      in_area { 'yes' }
      court { 'A Court' }
      hearing_outcome { 'CP01' }
      matter_type { '1' }
    end

    trait :with_uplift do
      reasons_for_claim { [ReasonForClaim::ENHANCED_RATES_CLAIMED.to_s] }
    end

    trait :case_disposal do
      plea { PleaOptions.values.reject(&:requires_date_field?).sample.to_s }
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
      rep_order_date { Date.yesterday }
      letters { 2 }
      calls { 3 }

      navigation_stack { |claim| ["/applications/#{claim.id}/steps/letters_calls"] }

      after(:build) do |claim, _context|
        claim.navigation_stack << "/applications/#{claim.id}/steps/letters_calls"
      end
    end

    trait :one_work_item do
      work_items { [build(:work_item, :valid)] }
    end

    trait :one_disbursement do
      disbursements { [build(:disbursement, :valid)] }
    end
  end
end
