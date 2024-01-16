FactoryBot.define do
  factory :prior_authority_application do
    provider { Provider.find_by(uid: 'test-user') || create(:provider) }
    office_code { '1A123B' }
    laa_reference { 'LAA-n4AohV' }
  end
end
