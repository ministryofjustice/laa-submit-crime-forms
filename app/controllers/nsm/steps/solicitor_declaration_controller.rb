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

      def record
        current_application
      end

      def check_complete?
        # In prior authority all we have to do is check that the check answers task is startable.
        # For Nsm you can technically end up with states where check answers is startable
        # but other tasks are incomplete. So we iterate through each task to check it's valid
        task_names = Nsm::StartPage::TaskList::SECTIONS.pluck(1).flatten - ['nsm/solicitor_declaration']
        incomplete = task_names.reject do |task_name|
          task_class = task_name.gsub('nsm', 'nsm/tasks').camelize.constantize
          task = task_class.new(application: current_application)
          task.not_applicable? || task.completed?
        end

        redirect_to nsm_steps_start_page_path(current_application) if incomplete.any?
      end
    end
  end
end
