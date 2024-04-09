FactoryBot.define do
  factory :solicitor do
    trait :valid do
      first_name { 'Richard' }
      last_name { 'Jenkins' }
      reference_number { '111222' }
    end

    trait :full do
      valid
      contact_first_name { 'James' }
      contact_last_name { 'Blake' }
      contact_email { 'james@email.com' }
    end
  end
end
