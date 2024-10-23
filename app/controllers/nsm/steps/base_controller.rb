module Nsm
  module Steps
    class BaseController < ::Steps::BaseStepController
      before_action :check_step_valid
      layout 'nsm'

      def check_step_valid
        redirect_to nsm_steps_view_claim_path(current_application) unless step_valid?
      end

      def step_valid?
        current_application.draft?
      end
    end
  end
end
