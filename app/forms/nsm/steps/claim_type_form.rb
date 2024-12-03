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
      # TODO: CRM457-2313: Disable this feature flag check
      validates :rep_order_date, presence: true,
              multiparam_date: { allow_past: true, allow_future: FeatureFlags.youth_court_fee.enabled? },
              if: :non_standard_claim?
      validates :cntp_order, presence: true, if: :breach_claim?
      # TODO: CRM457-2313: Disable this feature flag check
      validates :cntp_date, presence: true,
              multiparam_date: { allow_past: true, allow_future: FeatureFlags.youth_court_fee.enabled? },
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

      def should_reset_youth_court_fields?
        (breach_claim? && application.nsm?) ||
          (application.after_youth_court_cutoff? &&
            non_standard_claim? &&
            rep_order_date < Constants::YOUTH_COURT_CUTOFF_DATE)
      end

      private

      def persist!
        application.update!(attributes.merge(attributes_to_reset).merge(youth_court_attributes_to_reset))
      end

      def attributes_to_reset
        {
          'rep_order_date' => non_standard_claim? ? rep_order_date : nil,
          'cntp_order' => breach_claim? ? cntp_order : nil,
          'cntp_date' => breach_claim? ? cntp_date : nil,
          'office_in_undesignated_area' => non_standard_claim? ? application.office_in_undesignated_area : nil,
          'court_in_undesignated_area' => non_standard_claim? ? application.court_in_undesignated_area : nil,
          'transferred_to_undesignated_area' => non_standard_claim? ? application.transferred_to_undesignated_area : nil,

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
