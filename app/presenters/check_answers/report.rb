module CheckAnswers
  class Report < Base
    attr_reader :claim, :sections

    def initialize(claim)
      @claim = claim
      @sections = [
        section_group("about_you", about_you_section),
        section_group("about_defendant", about_defendant_section ),
        section_group("about_case", about_case_section ),
        section_group("about_claim", about_claim_section ),
        section_group("supporting_evidence", supporting_evidence_section )
      ]
    end

    def section_group(name, section_list)
      {
        heading: group_heading(name)
      }
    end

    def about_you_section
      [{ your_details: YourDetailsCard.new(claim) }]
    end

    def about_defendant_section
      [{ defendant_details: DefendantDetailsCard.new(claim) }]
    end

    def about_case_section
      [
        { case_details: CaseDetailsCard.new(claim) },
        { hearing_details: HearingDetailsCard.new(claim) },
        { case_disposal: CaseDisposalCard.new(claim) }
      ]
    end

    def about_claim_section
      [
        { claim_justification: ClaimJustificationCard.new(claim) },
        { claim_details: ClaimDetailsCard.new(claim) },
        { work_items: WorkItemsCard.new(claim) },
        { letters_calls: LettersCallsCard.new(claim) },
        { disbursement_costs: DisbursementCostsCard.new(claim) },
        { other_info: OtherInfoCard.new(claim) }
      ]
    end

    def supporting_evidence_section
      [{ evidence_upload: EvidenceUploadsCard.new(claim) }]
    end 
  end
end
