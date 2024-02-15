FactoryBot.define do
  factory :quote do
    contact_full_name { 'Joe Bloggs' }
    organisation { 'LAA' }
    postcode { 'CR0 1RE' }
    cost_per_hour { 10 }
    period { 180 }
    travel_cost_per_hour { 50.0 }
    travel_time { 150 }
    user_chosen_cost_type { 'per_hour' }
    document factory: %i[quote_document], strategy: :build

    trait :blank do
      contact_full_name { nil }
      organisation { nil }
      postcode { nil }
      primary { nil }
    end

    trait :primary do
      primary { true }
    end

    trait :alternative do
      primary { false }
    end
  end

  trait :no_document do
    document { nil }
  end
end
