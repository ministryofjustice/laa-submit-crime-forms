FactoryBot.define do
  factory :further_information do
    information_requested { 'please provider further evidence' }
    information_supplied { nil }
    caseworker_id { 'case-worker-uuid' }
    requested_at { DateTime.current }
    expired_at { 14.days.from_now }

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
