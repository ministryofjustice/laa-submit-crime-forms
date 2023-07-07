FactoryBot.define do
  factory :claim do
    id { SecureRandom.uuid }
    office_code { 'AAA' }

    trait :case_disposal do
      plea { PleaOptions.values.reject(&:requires_date_field?).sample.to_s }
    end

    trait :letters_calls do
      letters { 1 }
      calls { 1 }
    end
  end
end
