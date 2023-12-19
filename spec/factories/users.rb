FactoryBot.define do
  factory :caseworker, class: 'User' do
    email { 'case.worker@test.com' }
    first_name { 'case' }
    last_name { 'worker' }
    role { 'caseworker' }
    auth_uid { SecureRandom.uuid }
    auth_provider { 'azure_ad' }
    trait :deactivated do
      deactivated_at { Time.zone.now }
    end
  end

  factory :supervisor, class: 'User' do
    email { 'super.visor@test.com' }
    first_name { 'super' }
    last_name { 'visor' }
    role { 'supervisor' }
    auth_provider { 'azure_ad' }
    auth_uid { SecureRandom.uuid }
  end
end
