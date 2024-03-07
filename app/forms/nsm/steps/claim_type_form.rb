module Nsm
  module Steps
    class ClaimTypeForm < ::Steps::BaseFormObject
      attribute :ufn, :string
      attribute :claim_type, :value_object, source: ClaimType

      attribute :rep_order_date, :multiparam_date
      attribute :cntp_order, :string
      attribute :cntp_date, :multiparam_date

      validates :ufn, presence: true, ufn: true
      validates_inclusion_of :claim_type, in: :choices
      validates :rep_order_date, presence: true,
              multiparam_date: { allow_past: true, allow_future: false },
              if: :non_standard_claim?
      validates :cntp_order, presence: true, if: :breach_claim?
      validates :cntp_date, presence: true,
              multiparam_date: { allow_past: true, allow_future: false },
              if: :breach_claim?

      def choices
        ClaimType.values
      end

      def non_standard_claim?
        claim_type == ClaimType::NON_STANDARD_MAGISTRATE
      end

      def breach_claim?
        claim_type == ClaimType::BREACH_OF_INJUNCTION
      end

      private

      def persist!
        application.update!(attributes.merge(attributes_to_reset))
      end

      def attributes_to_reset
        {
          'rep_order_date' => non_standard_claim? ? rep_order_date : nil,
          'cntp_order' => breach_claim? ? cntp_order : nil,
          'cntp_date' => breach_claim? ? cntp_date : nil,
        }
      end
    end
  end
end
