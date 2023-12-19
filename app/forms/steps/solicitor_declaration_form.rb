require 'steps/base_form_object'

module Steps
  class SolicitorDeclarationForm < Steps::BaseFormObject
    attribute :signatory_name, :string
    validates :signatory_name, presence: true, format: { with: /\A[a-z,.'\-]+( +[a-z,.'\-]+)+\z/i }

    private

    def persist!
      application.status = :submitted
      build_costs
      application.update!(attributes)
      NotifyAppStore.new.process(claim: application)
    end

    def build_costs
      cost_totals(application).map do |record|
        application.costs.create(record)
      end
    end

    def cost_totals(application)
      [
        {
          'cost_type' => 'travel_and_waiting',
          'amount_with_vat' => CostCalculator.cost(:travel_and_waiting_total, application, true),
          'amount' => CostCalculator.cost(:travel_and_waiting_total, application, false)
        },
        {
          'cost_type' => 'core_costs',
          'amount_with_vat' => 0,
          'amount' => 0,
        },
        {
          'cost_type' => 'disbursements',
          'amount_with_vat' => 0,
          'amount' => 0
        }
      ]
    end
  end
end
