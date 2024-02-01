FactoryBot.define do
  factory :quote do
    service_type { 'Forensics Expert' }
    contact_full_name { 'Joe Bloggs' }
    organisation { 'LAA' }
    postcode { 'CR0 1RE' }
  end

  trait :blank do
    service_type { nil }
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
