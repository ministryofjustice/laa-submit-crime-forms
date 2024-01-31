module PriorAuthority
  module Tasks
    class PrimaryQuote < ::Tasks::Generic
      PREVIOUS_TASK = CaseAndHearingDetail
      FORM = ::PriorAuthority::Steps::PrimaryQuoteForm

      def path
        edit_prior_authority_steps_primary_quote_path(application)
      end

      def can_start?
        if application.prison_law === true
          fulfilled?(CaseAndHearingDetail)
        else
          if application.court_type == PriorAuthority::CourtTypeOptions::MAGISTRATE.to_s
            fulfilled?(CaseAndHearingDetail) && youth_court_form_filled?
          elsif application.court_type == PriorAuthority::CourtTypeOptions::CENTRAL_CRIMINAL.to_s
            fulfilled?(CaseAndHearingDetail) && psychiatric_liaison_form_filled?
          end
        end
      end

      def record
        application.primary_quote
      end

      private

      def youth_court_form_filled?
        application.youth_court.present?
      end

      def psychiatric_liaison_form_filled?
        Rails.logger.debug application.psychiatric_liaison_reason_not.present?
        application.psychiatric_liaison == true ? application.psychiatric_liaison : application.psychiatric_liaison_reason_not.present?
      end
    end
  end
end
