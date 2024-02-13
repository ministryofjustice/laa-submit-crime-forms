FactoryBot.define do
  factory :quote do
    service_type { 'pathologist_report' }
    custom_service_name { nil }
    contact_full_name { 'Joe Bloggs' }
    organisation { 'LAA' }
    postcode { 'CR0 1RE' }
    cost_per_hour { 10 }
    period { 180 }
    document factory: %i[quote_document], strategy: :build
  end

  trait :blank do
    service_type { nil }
    contact_full_name { nil }
    custom_service_name { nil }
    organisation { nil }
    postcode { nil }
    primary { nil }
  end

  trait :custom do
    service_type { 'custom' }
    custom_service_name { 'random service' }
  end

  trait :variable_cost do
    service_type { 'meteorologist' }
    user_chosen_cost_type { 'per_hour' }
  end

  trait :primary do
    primary { true }
  end

  trait :additional do
    primary { false }
  end

  trait :no_document do
    document { nil }
  end
end
