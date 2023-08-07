FactoryBot.define do
  factory :claim do
    id { SecureRandom.uuid }

    office_code { 'AAA' }

    trait :complete do
      firm_details
      main_defendant
      case_details
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

    trait :with_uplift do
      reasons_for_claim { [ReasonForClaim::ENHANCED_RATES_CLAIMED.to_s] }
    end

    trait :case_disposal do
      plea { PleaOptions.values.reject(&:requires_date_field?).sample.to_s }
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
