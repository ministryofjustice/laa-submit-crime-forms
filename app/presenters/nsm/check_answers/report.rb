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
        section_list.map do |data|
          {
            card: {
              title: data.title,
              actions: actions(data.section)
            },
            rows: data.rows
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
          CaseDisposalCard.new(claim)
        ]
      end

      def about_claim_section
        [
          ClaimJustificationCard.new(claim),
          ClaimDetailsCard.new(claim),
          WorkItemsCard.new(claim),
          LettersCallsCard.new(claim),
          DisbursementCostsCard.new(claim),
          OtherInfoCard.new(claim)
        ]
      end

      def supporting_evidence_section
        [
          EvidenceUploadsCard.new(claim)
        ]
      end

      private

      def actions(key)
        return [] if @readonly

        helper = Rails.application.routes.url_helpers
        [
          govuk_link_to(
            'Change',
            helper.url_for(controller: "nsm/steps/#{key}", action: :edit, id: claim.id, only_path: true)
          ),
        ]
      end

      def group_heading(group_key, **)
        I18n.t("steps.check_answers.groups.#{group_key}.heading", **)
      end
    end
  end
end
