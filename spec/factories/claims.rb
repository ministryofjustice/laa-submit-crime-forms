FactoryBot.define  do
  factory :claim do
    id { SecureRandom.uuid }
    office_code { 'AAA' }
  end
end