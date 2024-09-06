module Nsm
  module CheckAnswers
    class ReadOnlyReport
      include GovukLinkHelper
      include ActionView::Helpers::UrlHelper
      GROUPS = {
        status: %w[application_status].freeze,
        overview: %w[
          claim_type
          about_you
          about_defendant
          about_case
          about_claim
          supporting_evidence
          equality_answers
        ].freeze,
        claimed_costs: %w[cost_summary costs].freeze,
        adjustments: %w[adjusted_cost_summary adjusted_costs].freeze
      }.freeze

      attr_reader :claim

      def initialize(claim, cost_summary_in_overview: true)
        @claim = claim
        @cost_summary_in_overview = cost_summary_in_overview
      end

      def section_groups(section = :overview)
        GROUPS[section].map do |group_name|
          section_group(group_name, public_send(:"#{group_name}_section"))
        end
      end

      def section_group(name, section_list)
        {
          heading: group_heading(name),
          sections: section_list
        }
      end

      def application_status_section
        [ApplicationStatusCard.new(claim)]
      end

      def status_sections_for_print
        [
          ApplicationStatusCard.new(claim, skip_links: true),
          CostSummaryCard.new(claim,
                              show_adjustments: @claim.part_grant? || @claim.granted? || CostSummaryCard::SKIP_CELL,
                              skip_links: true)
        ]
      end

      def claim_type_section
        [ClaimTypeCard.new(claim)]
      end

      def about_you_section
        [YourDetailsCard.new(claim)]
      end

      def about_defendant_section
        [DefendantCard.new(claim)]
      end

      def about_case_section
        [
          CaseDetailsCard.new(claim),
          HearingDetailsCard.new(claim),
          CaseDisposalCard.new(claim)
        ]
      end

      def about_claim_section
        [
          ClaimJustificationCard.new(claim),
          ClaimDetailsCard.new(claim),
          (CostSummaryCard.new(claim) if @cost_summary_in_overview),
          OtherInfoCard.new(claim)
        ].compact
      end

      def costs_section
        [AdjustmentsCard.new(claim)]
      end

      def adjusted_costs_section
        [
          AdjustmentsCard.new(claim, prefix: 'allowed_')
        ]
      end

      def adjusted_cost_summary_section
        [
          CostSummaryCard.new(claim, show_adjustments: true, has_card: false)
        ]
      end

      def cost_summary_section
        [
          CostSummaryCard.new(claim, has_card: false)
        ]
      end

      def supporting_evidence_section
        [
          EvidenceUploadsCard.new(claim)
        ]
      end

      def equality_answers_section
        [
          EqualityAnswersCard.new(claim)
        ]
      end

      private

      def group_heading(group_key, **)
        return nil if group_key.in?(%w[costs claim_type])

        I18n.t("nsm.steps.check_answers.groups.#{group_key}.heading", **)
      end
    end
  end
end
