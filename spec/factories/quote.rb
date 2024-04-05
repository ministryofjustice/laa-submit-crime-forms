FactoryBot.define do
  factory :quote do
    contact_first_name { 'Joe' }
    contact_last_name { 'Bloggs' }
    organisation { 'LAA' }
    postcode { 'CR0 1RE' }
    cost_per_hour { 10 }
    period { 180 }
    travel_cost_per_hour { 50.0 }
    travel_time { 150 }
    user_chosen_cost_type { 'per_hour' }
    related_to_post_mortem { true }
    document factory: %i[quote_document], strategy: :build

    trait :blank do
      contact_first_name { nil }
      contact_last_name { nil }
      organisation { nil }
      postcode { nil }
      primary { nil }
    end

    trait :primary do
      primary { true }
    end

    trait :primary_per_item do
      primary { true }
      related_to_post_mortem { nil }
      cost_per_hour { nil }
      period { nil }
      cost_per_item { 10 }
      items { 100 }
      user_chosen_cost_type { 'per_item' }
    end

    trait :alternative do
      primary { false }
    end
  end

  trait :no_document do
    document { nil }
  end

  trait :with_additional_cost do
    additional_cost_total { 20 }
    additional_cost_list { 'Some things' }
  end

  trait :cost_per_item do
    cost_per_hour { nil }
    period { nil }
    cost_per_item { 10 }
    items { 2 }
  end
end
