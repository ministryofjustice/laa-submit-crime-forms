module TestData
  class NsmBuilder
    def initialize(data)
      @data = data
    end

    def build
      type, args = options.sample
      kwargs = args.pop if args.last.is_a?(Hash)
      claim = FactoryBot.create(*args)

      rand(40).times do
        FactoryBot.create(:work_item, claim: claim)
      end

      rand(type == :no_disbursements ? 0 : 10).times do
        FactoryBot.create(:disbursments, claim: claim)
      end

      SubmitToAppStore.new.submit(application)
    end

    def options
      {
        standard: [:claim, :complete],
        breach_of_injunction: [:claim, :complete, :case_type_breach],
        no_disbursements: [:claim, :complete, { disbursements: [] }],
        uplift: [:claim, :complete, :with_enhanced_rates],
      }
    end
  end
end