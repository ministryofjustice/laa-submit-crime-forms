module Nsm
  module Steps
    class CourtAreaForm < ::Steps::BaseFormObject
      attribute :court_in_undesignated_area, :boolean
      validates :court_in_undesignated_area, inclusion: { in: [true, false] }

      private

      def persist!
        application.update!(attributes.merge(attributes_to_reset))
      end

      def attributes_to_reset
        return {} if court_in_undesignated_area == application.court_in_undesignated_area

        {
          'transferred_to_undesignated_area' => nil,
        }
      end
    end
  end
end
