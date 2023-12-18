FactoryBot.define do
  factory :firm_office do
    trait :valid do
      name { 'Firm A' }
      account_number { '123ABC' }
      address_line_1 { '2 Laywer Suite' }
      town { 'Lawyer Town' }
      postcode { 'CR0 1RE' }
      vat_registered { 'yes' }
    end

    trait :full do
      valid
      address_line_2 { 'Unit B' }
      vat_registered { 'no' }
    end
  end
end
