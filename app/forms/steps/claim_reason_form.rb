require 'steps/base_form_object.rb'

module Steps
  class ClaimReasonForm < Steps::BaseFormObject
    attribute :claim_reason, :value_object, source: ClaimReason

    validates_inclusion_of :claim_reason, in: :options
    validates :rep_order_date, presence: true,
            multiparam_date: { allow_past: true, allow_future: false },
            if: :non_standard_claim?
    validates :cntp_order, presence: true, if: :breach_claim?
    validates :cntp_date, presence: true,
            multiparam_date: { allow_past: true, allow_future: false },
            if: :breach_claim?

    def options
      ClaimReason.values
    end

    def core_costs_exceed_higher?
      claim_reason == ClaimReason::CORE_COSTS_EXCEED_HIGHER_LMTS
    end

    def enhanced_rates_claim?
      claim_reason == ClaimReason::ENHANCED_RATES_CLAIMED
    end

    private

    def persist!
      application.update(
        attributes.merge(status_attributes)
      )
    end

    def status_attributes
      if claim_reason== ClaimReason::OTHER
        { status: :abandoned }
      else
        {}
      end
    end
  end
end
