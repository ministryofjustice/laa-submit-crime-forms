module Nsm
  module Steps
    class SolicitorDeclarationController < Nsm::Steps::BaseController
      before_action :check_complete?

      def edit
        @form_object = SolicitorDeclarationForm.build(
          record,
          application: current_application
        )
      end

      def update
        update_and_advance(SolicitorDeclarationForm, as: :solicitor_declaration, record: record)
      end

      private

      def decision_tree_class
        Decisions::DecisionTree
      end

      def record
        current_application.sent_back? ? current_application.pending_further_information : current_application
      end

      def step_valid?
        current_application.draft? || current_application.sent_back?
      end

      def check_complete?
        # In prior authority all we have to do is check that the check answers task is startable.
        # For Nsm you can technically end up with states where check answers is startable
        # but other tasks are incomplete. So we iterate through each task to check it's valid
        task_names = Nsm::StartPage::TaskList::SECTIONS.pluck(1).flatten
        incomplete = (task_names - ['nsm/solicitor_declaration']).reject do |task_name|
          task_class = task_name.gsub('nsm', 'nsm/tasks').camelize.constantize
          TaskList::TaskStatus.new.status(task_class: task_class, application: current_application).completed?
        end

        redirect_to nsm_steps_start_page_path(current_application) if incomplete.any?
      end
    end
  end
end
