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

      def completed?
        results = forms_for_completion_hash.each_with_object([]) do |(_k, form_hash), arr|
          arr << form_hash[:form].build(application).valid? if form_hash[:required]
        end
        results.all?(true)
      end

      private

      def forms_for_completion_hash
        {
          nh: { form: ::PriorAuthority::Steps::NextHearingForm,
                required: application.prison_law? },
          cd: { form: ::PriorAuthority::Steps::CaseDetailForm,
                required: !application.prison_law? },
          hd: { form: ::PriorAuthority::Steps::HearingDetailForm,
                required: !application.prison_law? },
          yc: { form: ::PriorAuthority::Steps::YouthCourtForm,
                required: youth_court_applicable? },
          pl: { form: ::PriorAuthority::Steps::PsychiatricLiaisonForm,
                required: psychiatric_liaison_applicable? },
        }
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
