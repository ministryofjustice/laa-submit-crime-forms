# frozen_string_literal: true

module Nsm
  module CheckAnswers
    class AdjustmentsCard < Base
      attr_reader :claim, :work_items

      def initialize(claim)
        @claim = claim
        @has_card = false
      end

      def rows
        nil
      end

      def custom
        {
          partial: 'nsm/steps/view_claim/adjustments',
          locals: { claim: }
        }
      end

      def title
        nil
      end
    end
  end
end
