module PriorAuthority
  module Tasks
    class ClientDetail < ::Tasks::Generic
      # TODO: Ufn is not the previous task, but it must be listed as such to allow
      # treating this task as can_start-able when Ufn is provided
      PREVIOUS_TASK = Ufn
      FORM = ::PriorAuthority::Steps::ClientDetailForm

      def path
        edit_prior_authority_steps_client_detail_path(application)
      end
    end
  end
end
