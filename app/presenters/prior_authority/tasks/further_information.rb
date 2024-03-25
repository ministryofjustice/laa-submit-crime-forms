module PriorAuthority
  module Tasks
    class FurtherInformation < Base
      PREVIOUS_TASKS = [
        PriorAuthority::Tasks::Ufn,
        PriorAuthority::Tasks::CaseContact,
        PriorAuthority::Tasks::ClientDetail,
        PriorAuthority::Tasks::CaseAndHearingDetail,
        PriorAuthority::Tasks::PrimaryQuote,
        PriorAuthority::Tasks::AlternativeQuotes,
        PriorAuthority::Tasks::ReasonWhy,
      ].freeze
      FORM = ::PriorAuthority::Steps::FurtherInformationForm

      def path
        edit_prior_authority_steps_further_information_path
      end

      def completed?
        FORM.build(record, application:).valid?
      end

      # This method assumes that the application is in a send back state and a
      # further information update is needed - the task wouldn't available on the
      # UI otherwise
      def record
        application.further_informations.last
      end
    end
  end
end
