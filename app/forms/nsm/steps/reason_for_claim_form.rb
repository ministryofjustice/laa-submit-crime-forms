module Steps
  class ReasonForClaimForm < Steps::BaseFormObject
    attribute :reasons_for_claim, array: true, default: []
    attribute :representation_order_withdrawn_date, :multiparam_date
    attribute :reason_for_claim_other_details, :string

    validate :validate_types
    validates :representation_order_withdrawn_date, presence: true,
            multiparam_date: { allow_past: true, allow_future: false },
            if: -> { reasons_for_claim.include?(ReasonForClaim::REPRESENTATION_ORDER_WITHDRAWN.to_s) }

    validates :reason_for_claim_other_details, presence: true,
            if: -> { reasons_for_claim.include?(ReasonForClaim::OTHER.to_s) }

    def validate_types
      errors.add(:reasons_for_claim, :blank) if reasons_for_claim.empty?
      errors.add(:reasons_for_claim, :invalid) if (reasons_for_claim - ReasonForClaim.values.map(&:to_s)).any?
    end

    def choices
      ReasonForClaim.values
    end

    def reasons_for_claim=(ary)
      super(ary.compact_blank) if ary
    end

    private

    def persist!
      application.update(attributes)
    end
  end
end
