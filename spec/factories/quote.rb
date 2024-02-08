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

  trait :additional do
    primary { false }
  end
end
