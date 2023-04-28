require 'steps/base_form_object'

module Steps
  class ReasonForClaimForm < Steps::BaseFormObject
    # attribute :reason_for_claim, :value_object, source: ReasonForClaim
    attribute :rep_order_date_withdrawn, :multiparam_date
    attribute :reason_for_claim_other, :string

    ReasonForClaim.each_value do |reason_for_claim|
      attribute reason_for_claim, :boolean
    end

    # validate :validate_types

    # ReasonForClaim.values.each do |reason_claim|
    #  validates reason_claim,
    #    presence: true,
    #    if: -> {types.include?(reason_claim.to_s)}
    # end
    # validates_inclusion_of :reason_for_claim, in: :choices

    def choices
      ReasonForClaim.values
    end

    # def core_costs_exceed_higher_limits?
    #  reason_for_claim == ReasonForClaim::CORE_COSTS_EXCEED_HIGHER_LMTS
    # end

    # def enhanced_rates_claim?
    #  reason_for_claim == ReasonForClaim::ENHANCED_RATES_CLAIMED
    # end

    private

    def persist!
      application.update(attributes)
    end
  end
end
