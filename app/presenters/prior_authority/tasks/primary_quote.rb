module PriorAuthority
  module Tasks
    class PrimaryQuote < Base
      PREVIOUS_TASKS = [
        PriorAuthority::Tasks::Ufn,
        PriorAuthority::Tasks::CaseContact,
        PriorAuthority::Tasks::ClientDetail,
        PriorAuthority::Tasks::CaseAndHearingDetail,
      ].freeze

      FORM = ::PriorAuthority::Steps::PrimaryQuoteForm

      def path
        if !travel_costs_complete?
          edit_prior_authority_steps_travel_detail_path(application)
        elsif first_steps_completed?
          prior_authority_steps_primary_quote_summary_path(application)
        else
          edit_prior_authority_steps_primary_quote_path(application)
        end
      end

      def can_start?
        fulfilled?(CaseAndHearingDetail) && fulfilled?(ClientDetail)
      end

      def record
        application.primary_quote
      end

      def completed?
        first_steps_completed? &&
          travel_costs_complete? &&
          all_additional_costs_completed?
      end

      def first_steps_completed?
        record &&
          FORM.build(record, application:).valid? &&
          PriorAuthority::Steps::ServiceCostForm.build(record, application:).valid?
      end

      def travel_costs_complete?
        # return true here as no record is the same as no data which is true
        return true unless record

        form = ::PriorAuthority::Steps::TravelDetailForm.build(record, application:)
        form.valid? || form.empty?
      end

      def all_additional_costs_completed?
        !application.additional_costs_still_to_add?
      end
    end
  end
end
