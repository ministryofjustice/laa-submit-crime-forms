require 'steps/base_form_object'

module Steps
  class ClaimTypeForm < Steps::BaseFormObject
    attribute :claim_type, :value_object, source: ClaimType

    attribute :rep_order_date, :multiparam_date
    attribute :cntp_order, :string
    attribute :cntp_date, :multiparam_date


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
      application.update(
        attributes
      )
    end
  end
end
