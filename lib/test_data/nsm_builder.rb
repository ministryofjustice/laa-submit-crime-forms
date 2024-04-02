module TestData
  class NsmBuilder
    def initialize(data)
      @data = data
    end

    def build
      type, args = options.sample
      args.pop if args.last.is_a?(Hash)
      claim = FactoryBot.create(*args)

      rand(40).times do
        FactoryBot.create(:work_item, claim:)
      end

      rand(type == :no_disbursements ? 0 : 10).times do
        FactoryBot.create(:disbursments, claim:)
      end

      SubmitToAppStore.new.submit(application)
    end

    # rubocop:disable  Metrics/MethodLength
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
    # rubocop:enable  Metrics/MethodLength
  end
end
