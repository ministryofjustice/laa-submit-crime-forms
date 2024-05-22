FactoryBot.define do
  factory :defendant do
    trait :valid do
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
      maat { '1234567' }
      position { 1 }
      main { true }
    end

    trait :additional do
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
      maat { '1234567' }
      position { 2 }
      main { false }
    end

    trait :valid_nsm do
      valid
    end

    trait :valid_paa do
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
      date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65) }
      maat { '1234567' }
    end

    trait :partial do
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
      main { true }
    end
  end
end
