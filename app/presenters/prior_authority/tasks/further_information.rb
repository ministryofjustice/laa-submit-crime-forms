module PriorAuthority
  module Tasks
    class FurtherInformation < Base
      FORM = ::PriorAuthority::Steps::FurtherInformationForm

      def path
        edit_prior_authority_steps_further_information_path
      end

      def completed?
        FORM.build(record, application:).valid?
      end

      def can_start?
        true
      end

      # This method assumes that the application is in a send back state and a
      # further information update is needed - the task wouldn't available on the
      # UI otherwise
      def record
        application.further_informations.order(:requested_at).last
      end
    end
  end
end
