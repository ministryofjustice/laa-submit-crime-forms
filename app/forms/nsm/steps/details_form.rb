module Nsm
  module Steps
    class DetailsForm < ::Steps::BaseFormObject
      attribute :ufn, :string
      attribute :rep_order_date, :multiparam_date

      validates :ufn, presence: true, ufn: true
      validates :rep_order_date, presence: true,
              multiparam_date: { allow_past: true, allow_future: false }


      def should_reset_youth_court_fields?
        application.after_youth_court_cutoff? && rep_order_date < Constants::YOUTH_COURT_CUTOFF_DATE
      end

      private

      def persist!
        if application.claim_type
          application.update!(attributes.merge(attributes_to_reset).merge(youth_court_attributes_to_reset))
        else
          application.create!(attributes.merge(initialized_attributes))
        end
      end

      def initialized_attributes
        {
          'id' => SecureRandom.uuid,
          'claim_type' => ClaimType::NON_STANDARD_MAGISTRATE
        }
      end

      def attributes_to_reset
        {
          'cntp_order' => nil,
          'cntp_date' => nil
        }
      end

      def youth_court_attributes_to_reset
        return {} unless should_reset_youth_court_fields?

        {
          'plea' => nil,
          'plea_category' => nil,
          'change_solicitor_date' => nil,
          'arrest_warrant_date' => nil,
          'include_youth_court_fee' => nil,
        }
      end
    end
  end
end
