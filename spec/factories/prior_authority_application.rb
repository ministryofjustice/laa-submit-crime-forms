FactoryBot.define do
  factory :prior_authority_application do
    provider { Provider.find_by(uid: 'test-user') || create(:provider) }
    office_code { '1A123B' }
    laa_reference { 'LAA-n4AohV' }

    trait :with_firm_and_solicitor do
      firm_office factory: %i[firm_office valid]
      solicitor factory: %i[solicitor full]
    end

    trait :with_defendant do
      defendant factory: %i[defendant valid], strategy: :build
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

    trait :about_request_enabled do
      ufn { '123456/001' }
      after(:create) do |paa, _a|
        create(:defendant, :valid_paa, defendable_id: paa.id, defendable_type: paa.class.to_s)
        paa.navigation_stack << "/prior-authority/applications/#{paa.id}/steps/ufn"
        paa.navigation_stack << "/prior-authority/applications/#{paa.id}/steps/client_detail"
        paa.save
      end
    end

    trait :full do
      with_firm_and_solicitor
      with_defendant
      with_psychiatric_liaison
      ufn { '123123/123' }
      client_maat_number { '123' }
      prison_law { true }
      reason_why { 'something' }
      main_offence { 'something' }
      client_detained { true }
      client_detained_prison { 'something' }
      subject_to_poca { true }
      next_hearing_date { 1.day.from_now }
      plea { 'something' }
      youth_court { 'something' }
      next_hearing { true }
      supporting_documents { build_list(:supporting_document, 2) }
    end
  end
end
