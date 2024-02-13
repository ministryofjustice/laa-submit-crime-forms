# TODO: This is a placeholder to show how the before_action would be implemented
# expect to repeat this before form submission as well.
#
module PriorAuthority
  module Steps
    class CheckAnswersController < Nsm::Steps::BaseController
      # before_action :check_complete?

      # def show
      #   @report = CheckAnswers::Report.new(current_application)
      # end

      # private

      # def check_complete?
      #   return if PriorAuthority::Tasks::CheckAnswers.new(application: current_application).status.complete?

      #   redirect_to prior_authority_steps_start_page_path(application)
      # end
    end
  end
end
