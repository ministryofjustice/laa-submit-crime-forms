FactoryBot.define do
  factory :defendant do
    id { SecureRandom.uuid }

    trait :valid do
      full_name { 'bobjim' }
      maat { 'AA1' }
      position { 1 }
      main { true }
    end

    trait :partial do
      full_name { 'bobjim' }
      position { 1 }
      main { true }
    end
  end
end
