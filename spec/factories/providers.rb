FactoryBot.define do
  factory :provider do
    auth_provider { 'saml' }
    uid { 'test-user' }
    office_codes { selected_office_codes }
    email { 'provider@example.com' }
    settings { { selected_office_code: } }

    trait :paa_access do
      paa_office_codes { ['BBBBBB'] }
      base_office_codes { [] }
    end

    trait :nsm_access do
      nsm_office_codes { ['AAAAAA'] }
      base_office_codes { [] }
    end

    trait :eol_access do
      eol_office_codes { ['CCCCCC'] }
      base_office_codes { [] }
    end

    transient do
      selected_office_code { office_codes[0] }
      selected_office_codes do
        [*paa_office_codes, *nsm_office_codes, *base_office_codes, *eol_office_codes]
      end
      paa_office_codes { [] }
      nsm_office_codes { [] }
      eol_office_codes { [] }
      base_office_codes { ['1A123B'] }
    end
  end
end
