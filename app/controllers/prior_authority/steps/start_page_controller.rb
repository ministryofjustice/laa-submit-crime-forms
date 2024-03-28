module PriorAuthority
  module Steps
    class StartPageController < BaseController
      def show
        # TODO: requires more routes and logic so leaving for future iterations once a completed PA is available
        # return redirect_to nsm_steps_view_claim_path(current_application.id) unless current_application.draft?
        @pre_tasklist = StartPage::PreTaskList.new(
          view_context, application: current_application, show_index: false
        )

        @tasklist = start_page_tasklist
        # # passed in separately to current_application to
        # # allow it to be wrapped in a presenter in the future
        @application = current_application
        render 'laa_multi_step_forms/task_list/show',
               locals: { header: -> {}, skip_progress: true, app_type: 'application' }
      end

      def start_page_tasklist
        if further_information_needed
          @tasklist || StartPage::FurtherInformationTaskList.new(
            view_context, application: current_application
          )
        else
          @tasklist || StartPage::TaskList.new(
            view_context, application: current_application
          )
        end
      end

      def further_information_needed
        if current_application.further_informations.empty?
          false
        else
          last_further_info_request = current_application.further_informations.last.created_at
          current_application.status == 'sent_back' && last_further_info_request > current_application.app_store_updated_at
        end
      end
    end
  end
end
