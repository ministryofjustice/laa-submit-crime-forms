require 'steps/base_form_object'

module Steps
  class ClaimTypeForm < Steps::BaseFormObject
    attribute :claim_type, :value_object, source: ClaimType
    attribute :claim_number, :string
    attribute :claim_date, :multiparam_date


    validates_inclusion_of :claim_type, in: :choices
    validates :claim_date, presence: true,
            multiparam_date: { allow_past: true, allow_future: false },
            if: :supported_claim_type?

    def choices
      ClaimType.values
    end

    def supported_claim_type?
      claim_type.supported?
    end

    private

    def persist!
      application.update(
        attributes
      )
    end
  end
end
