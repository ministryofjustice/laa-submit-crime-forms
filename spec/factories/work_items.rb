FactoryBot.define do
  factory :work_item do
    id { SecureRandom.uuid }

    trait :valid do
      work_type { WorkTypes.values.sample.to_s }
      time_spent { 100 }
      completed_on { Date.yesterday }
      fee_earner { 'jimbob' }
    end

    trait :partial do
      work_type { WorkTypes.values.sample.to_s }
      time_spent { 100 }
    end

    trait :with_uplift do
      valid
      uplift { '100' }
    end

    trait :medium_risk_values do
      work_type { WorkTypes::PREPARATION }
      time_spent { '100' }
      completed_on { Time.zone.today }
      fee_earner { 'test' }
    end

    WorkTypes.values.each do |value|
      trait value.to_s.to_sym do
        work_type { value.to_s }
      end
    end
  end
end
