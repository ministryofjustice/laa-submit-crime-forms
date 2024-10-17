module Nsm
  module Steps
    class WorkItemController < Nsm::Steps::BaseController
      before_action :ensure_work_item
      before_action :set_vat_flag

      def edit
        @form_object = WorkItemForm.build(
          work_item,
          application: current_application,
        )
      end

      def update
        update_and_advance(WorkItemForm,
                           as: :work_item,
                           record: work_item,
                           flash: build_flash)
      end

      private

      def decision_tree_class
        Decisions::DecisionTree
      end

      def work_item
        @work_item ||=
          if params[:work_item_to_duplicate]
            current_application.work_items.find_by(id: params[:work_item_to_duplicate]).dup
          elsif new_record?
            current_application.work_items.build(id: StartPage::NEW_RECORD)
          else
            current_application.work_items.find_by(id: params[:work_item_id])
          end
      end

      def ensure_work_item
        work_item || redirect_to(edit_nsm_steps_work_items_path(current_application))
      end

      def additional_permitted_params
        [:apply_uplift, :add_another]
      end

      def reload
        # Override the base class to not validate, so that if a user clicks 'Update calculation'
        # we don't tell them off for not answering 'Do you need to add another work item?' yet.
        render :edit
      end

      def new_record?
        params[:work_item_id] == StartPage::NEW_RECORD
      end

      def build_flash
        if new_record?
          if params.dig(:nsm_steps_work_item_form, :add_another) == YesNoAnswer::YES.to_s
            count = current_application.work_items.count + 1
            { success: t('.added', count: count, work_items: t('.work_item').pluralize(count)) }
          else
            {}
          end
        else
          { success: t('.updated') }
        end
      end

      def set_vat_flag
        @vat_included = current_application.firm_office&.vat_registered == YesNoAnswer::YES.to_s
      end
    end
  end
end
