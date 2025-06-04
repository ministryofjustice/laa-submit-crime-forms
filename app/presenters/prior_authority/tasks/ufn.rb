module PriorAuthority
  module Tasks
    class Ufn < Base
      FORM = ::PriorAuthority::Steps::UfnForm

      def path
        edit_prior_authority_steps_ufn_path
      end

      def can_start?
        true
      end
    end
  end
end
