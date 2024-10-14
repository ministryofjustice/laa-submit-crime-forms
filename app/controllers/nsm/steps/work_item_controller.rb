module Nsm
  module Steps
    class WorkItemController < Nsm::Steps::BaseController
      before_action :ensure_work_item

      def edit
        @form_object = WorkItemForm.build(
          work_item,
          application: current_application,
        )
        @vat_included = current_application.firm_office.vat_registered == YesNoAnswer::YES.to_s
      end

      def update
        count = current_application.work_items.count + 1
        flash = { success: t('.added', count: count, work_items: t('.work_item').pluralize(count)) }
        update_and_advance(WorkItemForm,
                           as: :work_item,
                           record: work_item,
                           flash: flash)
      end

      def duplicate
        if work_item.id == StartPage::NEW_RECORD
          redirect_to edit_nsm_steps_work_item_path(current_application, work_item_id: StartPage::NEW_RECORD)
        else
          new_work_item = work_item.dup
          new_work_item.save!
          redirect_to edit_nsm_steps_work_item_path(current_application, work_item_id: new_work_item.id),
                      flash: { success: t('.duplicate_success') }
        end
      end

      private

      def decision_tree_class
        Decisions::DecisionTree
      end

      def work_item
        @work_item ||=
          if params[:work_item_id] == StartPage::NEW_RECORD
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
    end
  end
end
