FactoryBot.define do
  factory :quote do
    service_type { 'pathologist_report' }
    custom_service_name { nil }
    contact_full_name { 'Joe Bloggs' }
    organisation { 'LAA' }
    document { nil }
    postcode { 'CR0 1RE' }
    cost_per_hour { 10 }
    period { 180 }
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

  trait :primary do
    primary { true }
  end

  trait :additional do
    primary { false }
  end

  trait :with_document do
    document { build(:quote_document) }
  end
end
