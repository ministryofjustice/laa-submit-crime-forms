FactoryBot.define do
  factory :claim do
    id { SecureRandom.uuid }
    office_code { 'AAA' }

    trait :costed do
      transient do
        work_types { WorkTypes.values.sample(2) }
        disbursement_types do
          Array.new(2) do
            type = DisbursementTypes.values.sample
            [type, type.other?]
          end
        end
      end

      letters { 2 }
      calls { 3 }
      rep_order_date { Date.yesterday }
      navigation_stack { |claim| ["/applications/#{claim.id}/steps/letters_calls"] }

      after(:build) do |claim, context|
        context.work_types.each do |work_type, time|
          claim.work_items << build(
            :work_item,
            work_type: work_type,
            time_spent: time || rand(100)
          )
        end
      end
    end
  end
end
