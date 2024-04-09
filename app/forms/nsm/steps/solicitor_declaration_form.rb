module Nsm
  module Steps
    class SolicitorDeclarationForm < ::Steps::BaseFormObject
      attribute :signatory_name, :string
      validates :signatory_name, presence: true, format: { with: /\A[a-z,.'\-]+( +[a-z,.'\-]+)+\z/i }

      private

      def persist!
        Claim.transaction do
          application.status = :submitted
          build_costs
          application.update!(attributes)
          SubmitToAppStore.new.process(submission: application)
          true
        end
      end

      def build_costs
        cost_totals(application).map do |record|
          application.cost_totals.create(record)
        end
      end

      # rubocop:disable Metrics/MethodLength
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
            'amount_with_vat' => CostCalculator.cost(:disbursement_total, application, true),
            'amount' => CostCalculator.cost(:disbursement_total, application, false)
          }
        ]
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
