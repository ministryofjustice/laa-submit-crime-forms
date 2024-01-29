FactoryBot.define do
  factory :quote do
    service_name { 'Forensics Expert' }
    contact_full_name { 'Joe Bloggs' }
    organisation { 'LAA' }
    postcode { 'CR0 1RE' }
  end

  trait :primary do
    primary { true }
  end

  trait :additional do
    primary { false }
  end
end
