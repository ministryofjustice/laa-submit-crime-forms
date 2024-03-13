FactoryBot.define do
  factory :additional_cost do
    name { 'A cost' }
    description { 'Loren ipsum' }

    trait :per_item do
      items { 2 }
      cost_per_item { 10.00 }
      unit_type { 'per_item' }
    end

    trait :per_hour do
      period { 70 }
      cost_per_hour { 10.00 }
      unit_type { 'per_hour' }
    end
  end
end
