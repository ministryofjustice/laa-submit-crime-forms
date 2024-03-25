module PriorAuthority
  module Tasks
    class FurtherInformation < Base
      # TODO: Ufn is not the previous task, but it must be listed as such to allow
      # treating this task as can_start-able when Ufn is provided
      PREVIOUS_TASKS = Ufn
      FORM = ::PriorAuthority::Steps::FurtherInformationForm

      def path
        edit_prior_authority_steps_further_information_path
      end

      def completed?
        record&.status == 'in_progress' && FORM.build(record, application:).valid?
      end

      def record
        application.further_informations.last
      end
    end
  end
end
