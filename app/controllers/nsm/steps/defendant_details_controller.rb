module Nsm
  module Steps
    class DefendantDetailsController < Nsm::Steps::BaseController
      include IncompleteItemsConcern

      before_action :ensure_defendant

      def edit
        @form_object = DefendantDetailsForm.build(
          defendant,
          application: current_application,
        )
      end

      def update
        update_and_advance(DefendantDetailsForm, as: :defendant_details, record: defendant)
      end

      private

      def defendant
        @defendant ||=
          if params[:defendant_id] == StartPage::NEW_RECORD
            current_application.defendants.build(id: StartPage::NEW_RECORD)
          else
            current_application.defendants.find_by(id: params[:defendant_id])
          end
      end

      # rubocop:disable Metrics/AbcSize
      def process_form(form_object, opts)
        if params.key?(:commit_draft)
          # Validations will not be run when saving a draft
          form_object.save!
          redirect_to opts[:after_commit_redirect_path] || nsm_after_commit_path(id: current_application.id)
        # :nocov:
        elsif params.key?(:reload)
          reload
        elsif params.key?(:save_and_refresh)
          form_object.save!
          redirect_to_current_object
        # :nocov:
        elsif form_object.save
          if incomplete_items_summary.incomplete_items.blank?
            flash_msg = { success: t('.edit.defendant_count', count: current_application.defendants.count) }
          end
          redirect_to decision_tree_class.new(form_object, as: opts.fetch(:as)).destination, flash: flash_msg
        else
          render opts.fetch(:render, :edit)
        end
      end
      # rubocop:enable Metrics/AbcSize

      def item_type
        :defendants
      end

      def ensure_defendant
        defendant || redirect_to(edit_nsm_steps_defendant_summary_path(current_application))
      end
    end
  end
end
