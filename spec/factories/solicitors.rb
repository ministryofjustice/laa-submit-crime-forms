FactoryBot.define do
  factory :solicitor do
    id { SecureRandom.uuid }

    trait :valid do
      full_name { 'Richard Jenkins' }
      reference_number { '111222' }
    end

    trait :full do
      valid
      contact_full_name { 'James Blake' }
      contact_email { 'james@email.com' }
    end
  end
end
