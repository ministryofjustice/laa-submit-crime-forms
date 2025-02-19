module Nsm
  module Steps
    class DisbursementsForm < ::Steps::AddAnotherForm
      def save
        unless all_disbursements_valid?
          errors.add(:add_another, :invalid_item, message: incomplete_items_summary.error_summary)
          return false
        end

        super
      end

      def all_disbursements_valid?
        application.disbursements.all?(&:complete?)
      end

      private

      def incomplete_items_summary
        Nsm::IncompleteItems.new(application, :disbursements, self)
      end
    end
  end
end
