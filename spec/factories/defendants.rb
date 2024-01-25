FactoryBot.define do
  factory :defendant do
    trait :valid do
      first_name { 'bob' }
      last_name { 'jim' }
      maat { 'AA1' }
      position { 1 }
      main { true }
    end

    trait :partial do
      first_name { 'bob' }
      last_name { 'jim' }
      main { true }
    end
  end
end
