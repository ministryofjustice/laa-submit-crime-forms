module Nsm
  module Steps
    class CaseTransferForm < ::Steps::BaseFormObject
      attribute :transferred_to_undesignated_area, :boolean
      validates :transferred_to_undesignated_area, inclusion: { in: [true, false] }

      private

      def persist!
        application.update!(attributes)
      end
    end
  end
end
