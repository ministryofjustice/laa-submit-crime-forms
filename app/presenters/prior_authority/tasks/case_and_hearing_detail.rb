module PriorAuthority
  module Tasks
    class CaseAndHearingDetail < Base
      PREVIOUS_TASKS = Ufn

      def path
        if application.prison_law?
          edit_prior_authority_steps_next_hearing_path
        else
          edit_prior_authority_steps_case_detail_path
        end
      end

      def completed?(rec = record, _form = nil)
        required_forms.all? { |form| super(rec, form) }
      end

      private

      def required_forms
        required_forms = []
        required_forms << ::PriorAuthority::Steps::NextHearingForm if application.prison_law?
        required_forms << ::PriorAuthority::Steps::CaseDetailForm unless application.prison_law?
        required_forms << ::PriorAuthority::Steps::HearingDetailForm unless application.prison_law?
        required_forms << ::PriorAuthority::Steps::YouthCourtForm if youth_court_applicable?
        required_forms << ::PriorAuthority::Steps::PsychiatricLiaisonForm if psychiatric_liaison_applicable?
        required_forms
      end

      def youth_court_applicable?
        application.court_type == CourtTypeOptions::MAGISTRATE.to_s
      end

      def psychiatric_liaison_applicable?
        application.court_type == CourtTypeOptions::CENTRAL_CRIMINAL.to_s
      end
    end
  end
end
