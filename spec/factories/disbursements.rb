FactoryBot.define do
  factory :disbursement do
    # using age as a shorthane  to set the disbursement date
    transient do
      age { rand(40) }
    end

    trait :valid do
      disbursement_date { age.days.ago.to_date }
      disbursement_type { DisbursementTypes.values.reject(&:other?).sample.to_s }
      miles { 50 + (200**rand).to_i } # range: 50 -> 250 with logorithmic distribution
      total_cost_without_vat do |disb|
        Pricing.for(Claim.new)[disb.disbursement_type] * disb.miles
      end
      prior_authority { total_cost_without_vat >= 100 ? 'yes' : 'no' }
      details { 'Details' }
      apply_vat { 'true' }
      vat_amount { apply_vat == 'true' ? total_cost_without_vat * 0.2 : nil }
    end

    trait :valid_type do
      disbursement_date { age.days.ago.to_date }
      disbursement_type { DisbursementTypes.values.reject(&:other?).sample.to_s }
    end

    trait :valid_other do
      disbursement_date { age.days.ago.to_date }
      disbursement_type { DisbursementTypes::OTHER.to_s }
      prior_authority { 'yes' }
      other_type { OtherDisbursementTypes.values.sample }
      total_cost_without_vat { 90.0 }
      prior_authority { 'yes' }
      details { 'Details' }
      apply_vat { 'false' }
      vat_amount { apply_vat == 'true' ? total_cost_without_vat * 0.2 : nil }
    end

    trait :valid_other_specific do
      disbursement_date { age.days.ago.to_date }
      disbursement_type { DisbursementTypes::OTHER.to_s }
      other_type { OtherDisbursementTypes.values[0] }
      total_cost_without_vat { 90.0 }
      prior_authority { 'yes' }
      details { 'Details' }
      apply_vat { 'true' }
    end

    trait :no_vat do
      disbursement_date { age.days.ago.to_date }
      disbursement_type { DisbursementTypes::OTHER.to_s }
      other_type { OtherDisbursementTypes.values[0] }
      total_cost_without_vat { 90.0 }
      prior_authority { 'yes' }
      details { 'Details' }
      apply_vat { 'false' }
    end

    trait :valid_high_cost do
      disbursement_date { age.days.ago.to_date }
      disbursement_type { DisbursementTypes::OTHER.to_s }
      other_type { OtherDisbursementTypes.values[0] }
      total_cost_without_vat { 5000.1 }
      prior_authority { 'yes' }
      details { 'Details' }
      apply_vat { 'true' }
    end

    trait :authed do
      total_cost_without_vat { 100.0 }
      details { 'Details' }
      prior_authority { 'yes' }
    end

    trait :partial do
      disbursement_date { Date.yesterday }
    end

    trait :with_adjustment do
      allowed_miles { 0 }
      allowed_total_cost_without_vat { 0 }
      allowed_apply_vat { apply_vat }
      allowed_vat_amount { (allowed_apply_vat || apply_vat) == 'true' ? 0 : nil }
      adjustment_comment { 'Disbursement Test' }
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
