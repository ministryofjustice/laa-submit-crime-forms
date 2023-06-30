FactoryBot.define do
  factory :disbursement do
    id { SecureRandom.uuid }

    trait :valid do
      disbursement_date { Date.yesterday }
      disbursement_type { (DisbursementTypes.values - [DisbursementTypes::OTHER]).sample.to_s }
      miles { 100 }
      total_cost_without_vat { 45.0 }
      details { 'Details' }
      apply_vat { 'no' }
    end

    trait :valid_other do
      disbursement_date { Date.yesterday }
      disbursement_type { DisbursementTypes::OTHER.to_s }
      other_type { OtherDisbursementTypes.values.sample }
      total_cost_without_vat { 90.0 }
      details { 'Details' }
      apply_vat { 'yes' }
    end

    trait :authed do
      total_cost_without_vat { 100.0 }
      details { 'Details' }
      prior_authority { 'yes' }
    end

    trait :partial do
      disbursement_date { Date.yesterday }
    end
  end
end
