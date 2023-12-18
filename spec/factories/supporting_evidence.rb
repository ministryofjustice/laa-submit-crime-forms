FactoryBot.define do
  factory :supporting_evidence do
    file_name { 'test.png' }
    file_type { 'image/png' }
    file_size { '1234' }
    created_at { Date.new(2023, 3, 1) }
    updated_at { Date.new(2023, 3, 1) }
    file_path { 'test_path' }
  end
end
