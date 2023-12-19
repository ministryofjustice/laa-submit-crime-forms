FactoryBot.define do
  factory :assignment do
    user factory: %i[caseworker]
    submitted_claim
  end
end
