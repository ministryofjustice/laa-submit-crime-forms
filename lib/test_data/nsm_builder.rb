module TestData
  class NsmBuilder
    def initialize(data)
      @data = data
    end

    def build
      last_form = nil
      forms.each do |form_class, data_field|
        form.new(
          data.public_send(data_field, application, last_form),
        ).save
      end
    end

    def forms
      {
        ClaimTypeForm => :claim_type,
        FirmDetailsForm => :firm_details,
        DefendantDetailsForm => :disbursement_details,
        CaseDetailsForm => :case_details,
        HearingDetailsForm => :hearing_details,
        CaseDisposalForm => :case_disposal,
        ReasonForClaimForm => :reason_for_claim,
        ClaimDetailsForm => :claim_details,
        WorkItemForm => :work_item,
        LettersCallsForm => :letters_calls,
        DisbursementCostForm => :disbursement_cost,
        DisbursementTypeForm => :disbursement_type,
        OtherInfoForm => :other_info,
        SupportingEvidenceForm => :supporting_evidence,
        AnswerEqualityForm => :answer_equality,
        EqualityQuestionsForm => :equality_questions,
        SolicitorDeclarationForm => :solicitor_declaration,
      }
    end

    def application
      @application ||= Claim.create!(
        office_code: current_office_code,
        submitter: current_provider,
        laa_reference: generate_laa_reference
      )
    end
  end
end