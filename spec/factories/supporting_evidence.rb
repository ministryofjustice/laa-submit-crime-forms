FactoryBot.define do
  factory :supporting_evidence do
    id { '9abe1541-00d7-43d1-ad10-4d3ee5a012bb' }
    claim_id { SecureRandom.uuid }
    file_name { 'test.png' }
    file_type { 'image/png' }
    file_size { '1234' }
    created_at { Date.new(2023, 3, 1) }
    updated_at { Date.new(2023, 3, 1) }
    file_path { 'test_path' }
  end
end
