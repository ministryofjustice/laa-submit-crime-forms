FactoryBot.define do
  factory :further_information do
    information_requested { 'please provide further evidence' }
    information_supplied { nil }
    caseworker_id { '87e88ac6-d89a-4180-80d4-e03285023fb0' }
    requested_at { DateTime.new(2024, 1, 1, 1, 1, 1) }
    created_at { DateTime.current }

    trait :with_response do
      information_supplied { 'here is the extra information you requested' }
    end

    trait :with_supporting_documents do
      supporting_documents do
        [
          build(:supporting_document, file_name: 'further_info1.pdf'),
          build(:supporting_document, file_name: 'further_info2.pdf'),
        ]
      end
    end
  end
end
