module Nsm
  module Steps
    class BoiDetailsForm < ::Steps::BaseFormObject
      attribute :ufn, :string
      attribute :cntp_order, :string
      attribute :cntp_date, :multiparam_date

      validates :ufn, presence: true, ufn: true
      validates :cntp_order, presence: true
      validates :cntp_date, presence: true,
              multiparam_date: { allow_past: true, allow_future: false }


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
          'claim_type' => ClaimType::BREACH_OF_INJUNCTION
        }
      end

      def attributes_to_reset
        {
          'rep_order_date' => nil,
          'office_in_undesignated_area' => nil,
          'court_in_undesignated_area' => nil,
          'transferred_to_undesignated_area' => nil,
        }
      end

      def youth_court_attributes_to_reset
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
