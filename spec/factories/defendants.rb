FactoryBot.define do
  factory :defendant do
    trait :valid do
      first_name { 'bob' }
      last_name { 'jim' }
      maat { 'AA1' }
      position { 1 }
      main { true }
    end

    trait :valid_paa do
      first_name { 'bob' }
      last_name { 'jim' }
      date_of_birth { Date.new(1981, 11, 12) }
    end

    trait :partial do
      first_name { 'bob' }
      last_name { 'jim' }
      main { true }
    end
  end
end
