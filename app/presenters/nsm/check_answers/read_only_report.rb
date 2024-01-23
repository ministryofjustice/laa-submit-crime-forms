module CheckAnswers
  class ReadOnlyReport
    include GovukLinkHelper
    include ActionView::Helpers::UrlHelper
    GROUPS = %w[
      application_status
      claim_type
      about_you
      about_defendant
      about_case
      about_claim
      supporting_evidence
      equality_answers
    ].freeze

    attr_reader :claim

    def initialize(claim)
      @claim = claim
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

    def application_status_section
      [ApplicationStatusCard.new(claim)]
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

    def equality_answers_section
      [
        EqualityAnswersCard.new(claim)
      ]
    end

    private

    def actions(_key)
      []
    end

    def group_heading(group_key, **)
      I18n.t("steps.check_answers.groups.#{group_key}.heading", **)
    end
  end
end
