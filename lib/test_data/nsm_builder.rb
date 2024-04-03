module TestData
  class NsmBuilder
    def build_many(count)
      count.times { build }
    end

    def build
      args, kwargs = *options.values.sample
      claim = FactoryBot.create(*args, kwargs.call)

      SubmitToAppStore.new.submit(claim)
    end

    # rubocop:disable Metrics/MethodLength
    def options
      {
        magistrates: [
          [:claim, :complete, :case_type_magistrates],
          (lamda { { disbursements_count: rand(25), work_items_count: rand(50) } })
        ],
        breach: [
          [:claim, :complete, :case_type_breach],
          (lamda { { disbursements_count: rand(25), work_items_count: rand(50) } })
        ],
        no_disburesments: [
          [:claim, :complete, :case_type_magistrates],
          (lamda { { disbursements_count: 0, work_items_count: rand(50) } })
        ],
        enhanced_rates: [
          [:claim, :complete, :case_type_magistrates, :with_enhanced_rates],
          (lamda { { disbursements_count: rand(25), work_items_count: rand(50) } })
        ],
      }
    end
    # rubocop:enable Metrics/MethodLength
  end
end
