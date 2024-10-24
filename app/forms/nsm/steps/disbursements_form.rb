module Nsm
  module Steps
    class DisbursementsForm < ::Steps::AddAnotherForm
      def save
        unless all_disbursements_valid?
          errors.add(:add_another, :invalid_item)
          return false
        end

        super
      end

      def all_disbursements_valid?
        application.disbursements.all?(&:complete?)
      end
    end
  end
end
