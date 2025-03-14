FactoryBot.define do
  factory :work_item do
    completed_on { Time.zone.today }

    trait :valid do
      work_type { [WorkTypes::ATTENDANCE_WITHOUT_COUNSEL, WorkTypes::PREPARATION, WorkTypes::ADVOCACY].sample.to_s }
      time_spent { 50 + (400**rand).to_i } # range: 50 -> 450 with logorithmic distribution
      completed_on { rand(40).days.ago.to_date }
      fee_earner { Faker::Name.name.split.map(&:first).join }
      uplift { 0 }
    end

    trait :partial do
      work_type { WorkTypes.values.sample.to_s }
      time_spent { 100 }
    end

    trait :with_uplift do
      valid
      uplift { '100' }
    end

    trait :high_profit_cost do
      valid
      work_type { WorkTypes::ATTENDANCE_WITHOUT_COUNSEL }
      time_spent { 60_000 }
    end

    trait :medium_risk_values do
      work_type { WorkTypes::PREPARATION }
      time_spent { '100' }
      completed_on { Time.zone.today }
      fee_earner { 'TT' }
    end

    trait :travel do
      work_type { WorkTypes::TRAVEL }
      time_spent { '100' }
      uplift { 10 }
      completed_on { Time.zone.today }
      fee_earner { 'TT' }
    end

    trait :waiting do
      work_type { WorkTypes::WAITING }
      time_spent { '100' }
      uplift { 10 }
      completed_on { Time.zone.today }
      fee_earner { 'TT' }
    end

    trait :with_adjustment do
      allowed_time_spent { time_spent / 2 }
      adjustment_comment { 'WI adjustment' }
    end

    # rubocop:disable Style/HashEachMethods
    WorkTypes.values.each do |value|
      trait value.to_s.to_sym do
        work_type { value.to_s }
      end
    end
    # rubocop:enable Style/HashEachMethods
  end
end
