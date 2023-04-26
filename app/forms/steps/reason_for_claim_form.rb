require 'steps/base_form_object.rb'

module Steps
  class ReasonForClaimForm < Steps::BaseFormObject
    attribute :reason_for_claim, :value_object, source: ReasonForClaim


    validates_inclusion_of :reason_for_claim, in: :options

    def options
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
      application.update(
        attributes.merge(status_attributes)
      )
    end

    def status_attributes
      if reason_for_claim== ReasonForClaim::OTHER
        { status: :abandoned }
      else
        {}
      end
    end
  end
end
