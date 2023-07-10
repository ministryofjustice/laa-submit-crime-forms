FactoryBot.define do
  factory :claim do
    id { SecureRandom.uuid }
    office_code { 'AAA' }

    trait :letters_calls do
      rep_order_date { Date.yesterday }
      letters { 2 }
      calls { 3 }

      navigation_stack { |claim| ["/applications/#{claim.id}/steps/letters_calls"] }

      after(:build) do |claim, _context|
        claim.navigation_stack << "/applications/#{claim.id}/steps/letters_calls"
      end
    end
  end
end
