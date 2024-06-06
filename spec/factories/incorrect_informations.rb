FactoryBot.define do
  factory :incorrect_information do
    information_requested { 'Please update the case details' }
    caseworker_id { '87e88ac6-d89a-4180-80d4-e03285023fb0' }
    requested_at { DateTime.new(2024, 1, 1, 1, 1, 1) }
    created_at { DateTime.current }

    trait :with_edits do
      sections_changed { ['case_details'] }
    end
  end
end
