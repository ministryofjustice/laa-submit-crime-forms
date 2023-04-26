require 'steps/base_form_object.rb'

module Steps
  class ReasonForClaimForm < Steps::BaseFormObject
    attribute :reason_for_claim, :value_object, source: ReasonForClaim

    #attribute :reasons, array: true, default: []
    attribute :reason_for_claim, array: true, default: []

    ReasonForClaim.values.each do |reason_claim|
      attribute reason_claim, :value_object
    end


    #validates_inclusion_of :reason_for_claim, in: :choices

    def choices
      ReasonForClaim.values
    end

    def core_costs_exceed_higher?
      reason_for_claim == ReasonForClaim::CORE_COSTS_EXCEED_HIGHER_LMTS
    end

    def enhanced_rates_claim?
      reason_for_claim == ReasonForClaim::ENHANCED_RATES_CLAIMED
    end

    private

    def persist!
      debugger
      application.update(
        attributes.merge(status_attributes)
      )
    end

  end
end
