# frozen_string_literal: true

module Nsm
  module CheckAnswers
    class AdjustmentsCard < Base
      attr_reader :claim, :work_items, :prefix

      def initialize(claim, prefix: '')
        @claim = claim
        @has_card = false
        @prefix = prefix
      end

      def rows
        nil
      end

      def custom
        {
          partial: 'nsm/steps/view_claim/adjustments',
          locals: { claim:, prefix: }
        }
      end

      def title
        nil
      end
    end
  end
end
