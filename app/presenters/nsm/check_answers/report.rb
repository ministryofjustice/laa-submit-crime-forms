module Nsm
  module CheckAnswers
    class Report
      include GovukLinkHelper
      include GovukVisuallyHiddenHelper
      include ActionView::Helpers::UrlHelper
      GROUPS = %w[
        claim_type
        about_you
        about_defendant
        about_case
        about_claim
        supporting_evidence
      ].freeze

      GROUPS_WITHOUT_HEADING = %w[claim_type].freeze

      attr_reader :claim

      def initialize(claim, read_only: false)
        @claim = claim
        @readonly = read_only
      end

      def section_groups
        GROUPS.map do |group_name|
          section_group(group_name, public_send(:"#{group_name}_section"))
        end
      end

      def section_group(name, section_list)
        {
          heading: group_heading(name),
          sections: sections(section_list)
        }
      end

      def sections(section_list)
        section_list.map do |card|
          {
            card: {
              title: card.title,
              actions: actions(card.section, card.change_link_controller_method)
            },
            rows: card.rows,
            custom: card.custom
          }
        end
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
          case_disposal_form
        ]
      end

      def about_claim_section
        [
          ClaimJustificationCard.new(claim),
          ClaimDetailsCard.new(claim),
          CostSummaryCard.new(claim),
          OtherInfoCard.new(claim)
        ]
      end

      def supporting_evidence_section
        [
          EvidenceUploadsCard.new(claim)
        ]
      end

      private

      def case_disposal_form
        ycf_flow = FeatureFlags.youth_court_fee.enabled? && claim.rep_order_date >= Constants::YOUTH_COURT_CUTOFF_DATE

        return CaseCategoryCard.new(claim) if ycf_flow

        CaseDisposalCard.new(claim)
      end

      def actions(key, action)
        return [] if @readonly

        helper = Rails.application.routes.url_helpers
        [
          govuk_link_to(
            I18n.t('generic.change'),
            helper.url_for(controller: "nsm/steps/#{key}", action: action, id: claim.id, only_path: true)
          ),
        ]
      end

      def group_heading(group_name)
        return if GROUPS_WITHOUT_HEADING.include?(group_name)

        I18n.t("nsm.steps.check_answers.groups.#{group_name}.heading")
      end
    end
  end
end
