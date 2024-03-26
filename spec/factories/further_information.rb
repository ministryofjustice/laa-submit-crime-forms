FactoryBot.define do
  factory :further_information do
    trait :valid do
      information_requested { 'need some information' }
      information_supplied { 'some information' }
      caseworker_id { 'c19645b3-8e72-420b-89bc-47d59b75c40c' }
      requested_at { DateTime.current }
    end
  end
end
