FactoryBot.define do
  factory :disbursement do
    id { SecureRandom.uuid }

    # using age as a shorthane  to set the disbursement date
    transient do
      age { 1 }
    end

    trait :valid do
      disbursement_date { age.days.ago.to_date }
      disbursement_type { DisbursementTypes.values.reject(&:other?).sample.to_s }
      miles { 100 }
      total_cost_without_vat do |disb|
        Pricing.for(Claim.new)[disb.disbursement_type] * disb.miles
      end
      details { 'Details' }
      apply_vat { 'no' }
    end

    trait :valid_type do
      disbursement_date { age.days.ago.to_date }
      disbursement_type { DisbursementTypes.values.reject(&:other?).sample.to_s }
    end

    trait :valid_other do
      disbursement_date { age.days.ago.to_date }
      disbursement_type { DisbursementTypes::OTHER.to_s }
      other_type { OtherDisbursementTypes.values.sample }
      total_cost_without_vat { 90.0 }
      details { 'Details' }
      apply_vat { 'yes' }
    end

    trait :valid_other_specific do
      disbursement_date { age.days.ago.to_date }
      disbursement_type { DisbursementTypes::OTHER.to_s }
      other_type { OtherDisbursementTypes.values[0] }
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

    DisbursementTypes.values.each do |type|
      trait type.to_s.to_sym do
        disbursement_type { type.to_s }
        other_type { nil }
      end
    end

    OtherDisbursementTypes.values.each do |type|
      trait type.to_s.to_sym do
        disbursement_type { DisbursementTypes::OTHER.to_s }
        other_type { type.to_s }
      end
    end
  end
end
