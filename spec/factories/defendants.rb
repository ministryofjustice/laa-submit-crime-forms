FactoryBot.define do
  factory :defendant do
    trait :valid do
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
      maat { 'AA1' }
      position { 1 }
      main { true }
    end

    trait :valid_paa do
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
      date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65) }
      maat { '1234' }
    end

    trait :partial do
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
      main { true }
    end
  end
end
