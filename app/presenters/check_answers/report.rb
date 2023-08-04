module CheckAnswers
  class Report
    include GovukLinkHelper
    include ActionView::Helpers::UrlHelper

    attr_reader :claim, :section_groups

    def initialize(claim)
      @claim = claim
      @section_groups = [
        section_group('about_you', about_you_section),
        # section_group('about_defendant', about_defendant_section),
        # section_group('about_case', about_case_section),
        # section_group('about_claim', about_claim_section),
        # section_group('supporting_evidence', supporting_evidence_section)
      ]
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
          rows: [*data.rows]
        }
      end
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
      helper = Rails.application.routes.url_helpers
      [
        govuk_link_to(
          'Change',
          helper.url_for(controller: "steps/#{key}", action: :edit, id: claim.id, only_path: true)
        ),
      ]
    end

    def group_heading(group_key, **)
      I18n.t("steps.check_answers.groups.#{group_key}.heading", **)
    end
  end
end
