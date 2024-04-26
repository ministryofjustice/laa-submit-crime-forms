module Nsm
  module CostSummary
    class Summary < Base
      PROFIT_COSTS_WORK_TYPES = %w[attendance_with_counsel attendance_without_counsel preparation advocacy].freeze

      def initialize(claim)
        @claim = claim
      end

      def profit_costs_net
        @profit_costs_net ||= work_items_total(PROFIT_COSTS_WORK_TYPES) + (letters_and_calls_form.total_cost || 0)
      end

      def profit_costs_vat
        @profit_costs_vat ||= vat_registered ? profit_costs_net * vat_rate : 0
      end

      def profit_costs_gross
        @profit_costs_gross ||= profit_costs_net + profit_costs_vat
      end

      def waiting_net
        @waiting_net ||= work_items_total(:waiting)
      end

      def waiting_vat
        @waiting_vat ||= vat_registered ? waiting_net * vat_rate : 0
      end

      def waiting_gross
        @waiting_gross ||= waiting_net + waiting_vat
      end

      def travel_net
        @travel_net ||= work_items_total(:travel)
      end

      def travel_vat
        @travel_vat ||= vat_registered ? travel_net * vat_rate : 0
      end

      def travel_gross
        @travel_gross ||= travel_net + travel_vat
      end

      def disbursements_net
        @disbursements_net ||= disbursement_forms.sum(&:total_cost_pre_vat) || 0
      end

      def disbursements_vat
        @disbursements_vat ||= disbursement_forms.sum(&:vat) || 0
      end

      def disbursements_gross
        @disbursements_gross ||= disbursement_forms.sum(&:total_cost) || 0
      end

      def total_net
        profit_costs_net + waiting_net + travel_net + disbursements_net
      end

      def total_vat
        profit_costs_vat + waiting_vat + travel_vat + disbursements_vat
      end

      def total_gross
        profit_costs_gross + waiting_gross + travel_gross + disbursements_gross
      end

      private

      def work_items_total(work_type)
        total = @claim.work_items.where(work_type:).sum do |work_item|
          Nsm::Steps::WorkItemForm.build(work_item, application: @claim).total_cost
        end
        total || 0
      end

      def letters_and_calls_form
        @letters_and_calls_form ||= Nsm::Steps::LettersCallsForm.build(@claim)
      end

      def disbursement_forms
        @disbursement_forms ||= @claim.disbursements.map do |disbursement|
          Nsm::Steps::DisbursementCostForm.build(disbursement, application: @claim)
        end
      end
    end
  end
end