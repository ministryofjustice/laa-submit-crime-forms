FactoryBot.define do
  factory :provider, class: 'User' do
    role { 'provider' }
    auth_provider { 'saml' }
    auth_uid { 'test-user' }
    office_codes { ['1A123B'] }
    email { 'provider@example.com' }
    settings { { selected_office_code: '1A123B' } }
  end

  factory :user do
    role { 'provider' }
    auth_provider { 'saml' }
    auth_uid { 'test-user' }
    office_codes { ['1A123B'] }
    email { 'provider@example.com' }
    settings { { selected_office_code: '1A123B' } }
  end
end
