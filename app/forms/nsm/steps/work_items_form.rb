module Nsm
  module Steps
    class WorkItemsForm < ::Steps::AddAnotherForm
      def save
        unless all_work_items_valid?
          errors.add(:add_another, :invalid_item, message: incomplete_items_summary.error_summary)
          return false
        end

        super
      end

      def all_work_items_valid?
        application.work_items.all?(&:complete?)
      end

      private

      def incomplete_items_summary
        Nsm::IncompleteItems.new(application, :work_items, self)
      end
    end
  end
end
