module Nsm
  module Tasks
    class PriorAuthorityUfn < Nsm::Tasks::Generic
      FORM = ::PriorAuthority::Steps::UfnForm

      def path
        edit_prior_authority_steps_ufn_path(application)
      end

      def can_start?
        true
      end
    end
  end
end
