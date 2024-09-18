module Nsm
  module Steps
    class OfficeAreaForm < ::Steps::BaseFormObject
      attribute :office_in_undesignated_area, :boolean
      validates :office_in_undesignated_area, inclusion: { in: [true, false] }

      private

      def persist!
        application.update!(attributes.merge(attributes_to_reset))
      end

      def attributes_to_reset
        return {} if office_in_undesignated_area == application.office_in_undesignated_area

        {
          'court_in_undesignated_area' => nil,
          'transferred_to_undesignated_area' => nil,
        }
      end
    end
  end
end
