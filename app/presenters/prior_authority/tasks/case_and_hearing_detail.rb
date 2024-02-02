module PriorAuthority
  module Tasks
    class CaseAndHearingDetail < Base
      PREVIOUS_TASK = Ufn

      def path
        if application.prison_law?
          edit_prior_authority_steps_next_hearing_path
        else
          edit_prior_authority_steps_case_detail_path
        end
      end

      def completed?(_rec = record, _form = associated_form)
        required_forms.all? { |form| super(record, form) }
      end

      private

      def required_forms
        previous_tasks = []
        previous_tasks << ::PriorAuthority::Steps::NextHearingForm if application.prison_law?
        previous_tasks << ::PriorAuthority::Steps::CaseDetailForm unless application.prison_law?
        previous_tasks << ::PriorAuthority::Steps::HearingDetailForm unless application.prison_law?
        previous_tasks << ::PriorAuthority::Steps::YouthCourtForm if youth_court_applicable?
        previous_tasks << ::PriorAuthority::Steps::PsychiatricLiaisonForm if psychiatric_liaison_applicable?
        previous_tasks
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
