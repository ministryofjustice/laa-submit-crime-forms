module Nsm
  module Steps
    class StartPageController < Nsm::Steps::BaseController
      def show
        @pre_tasklist = StartPage::PreTaskList.new(
          view_context, application: current_application, show_index: false
        )
        @tasklist = StartPage::TaskList.new(
          view_context, application: current_application
        )
        # passed in separately to current_application to
        # allow it to be wrapped in a presenter in the future
        @application = current_application
        flash.now[:alert] = t('nsm.steps.supporting_evidence.edit.gdpr_msg') if current_application.gdpr_documents_deleted?
        render 'laa_multi_step_forms/task_list/show', locals: { app_type: 'claim' }
      end

      # we remove the check_answers entry from the list to reset the return
      # location after edits once the task list has been displayed
      def update_viewed_steps
        current_application.viewed_steps -= ['check_answers']

        super
      end
    end
  end
end
