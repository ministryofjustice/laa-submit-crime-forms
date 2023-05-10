require 'steps/base_form_object'

module Steps
  class CaseDisposalForm < Steps::BaseFormObject
    attribute :plea, :value_object, source: Plea
    validates_inclusion_of :plea, in: :choices

    def choices
      Plea.values
    end

    private

    def persist!
      application.update!(attributes)
    end
  end
end
