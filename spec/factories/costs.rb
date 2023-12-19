FactoryBot.define do
  factory :cost do
    trait :travel_and_waiting do
      cost_type { 'travel_and_waiting' }
      amount { 100 }
      amount_with_vat { 110 }
    end

    trait :core_costs do
      cost_type { 'core_costs' }
      amount { 100 }
      amount_with_vat { 110 }
    end

    trait :disbursements do
      cost_type { 'disbursements' }
      amount { 100 }
      amount_with_vat { 110 }
    end
  end
end
