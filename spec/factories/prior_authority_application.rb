FactoryBot.define do
  factory :prior_authority_application do
    provider { Provider.find_by(uid: 'test-user') || create(:provider) }
    office_code { '1A123B' }
    laa_reference { 'LAA-n4AohV' }

    trait :with_firm_and_solicitor do
      firm_office factory: %i[firm_office valid]
      solicitor factory: %i[solicitor valid]
    end

    trait :with_psychiatric_liaison do
      court_type { 'central_criminal_court' }
      youth_court { nil }
      psychiatric_liaison { false }
      psychiatric_liaison_reason_not { 'whatever you like' }
    end

    trait :with_youth_court do
      court_type { 'magistrates_court' }
      youth_court { true }
      psychiatric_liaison { nil }
      psychiatric_liaison_reason_not { nil }
    end

    trait :with_primary_quote do
      primary_quote { build(:quote) }
    end
  end
end
