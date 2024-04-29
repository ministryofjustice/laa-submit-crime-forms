# frozen_string_literal: true

module Nsm
  module CheckAnswers
    class CostSummaryCard < Base
      attr_reader :claim, :work_items

      def initialize(claim, has_card: true)
        @claim = claim
        @group = 'about_claim'
        @section = 'cost_summary'
        @has_card = has_card
      end

      def rows
        nil
      end

      def custom
        {
          partial: 'nsm/steps/cost_summary/summary_table',
          locals: { summary: Nsm::CostSummary::Summary.new(claim), hide_caption: true }
        }
      end

      def change_link_controller_method
        :show
      end
    end
  end
end
