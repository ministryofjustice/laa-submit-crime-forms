FactoryBot.define do
  factory :quote do
    contact_full_name { 'Joe Bloggs' }
    organisation { 'LAA' }
    postcode { 'CR0 1RE' }
    cost_per_hour { 10 }
    period { 180 }
    document factory: %i[quote_document], strategy: :build
  end

  trait :per_item do
    user_chosen_cost_type { 'per_item' }
    cost_per_item { 1.00 }
    items { 2 }
  end

  trait :variable_cost do
    travel_cost_per_hour { 50.0 }
    travel_time { 150 }
    user_chosen_cost_type { 'per_hour' }
  end

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

  trait :no_document do
    document { nil }
  end
end
