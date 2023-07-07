FactoryBot.define do
  factory :claim do
    id { SecureRandom.uuid }
    office_code { 'AAA' }

    trait :case_details do
      ufn { '20150612/001' }
      main_offence { 'theft' }
      main_offence_date { Date.yesterday }

      assigned_counsel { 'no' }
      unassigned_counsel { 'no' }
      agent_instructed { 'no' }
      remitted_to_magistrate { 'no' }
    end

    trait :case_disposal do
      plea { PleaOptions.values.reject(&:requires_date_field?).sample.to_s }
    end

    trait :letters_calls do
      letters { 1 }
      calls { 1 }
    end
  end
end
