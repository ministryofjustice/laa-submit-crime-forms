require 'steps/base_form_object'

module Steps
  class ClaimDetailsForm < Steps::BaseFormObject
    BOOLEAN_FIELDS = %i[supplemental_claim preparation_time].freeze

    attribute :prosecution_evidence, :string
    attribute :defence_statement, :string
    attribute :number_of_witnesses, :integer
    attribute :time_spent, :time_period

    validates :prosecution_evidence, presence: true
    validates :defence_statement, presence: true
    validates :number_of_witnesses, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :time_spent, numericality: { only_integer: true, greater_than: 0 }, time_period: true,
      if: ->(form) { form.preparation_time == YesNoAnswer::YES }

    BOOLEAN_FIELDS.each do |field|
      validates field, presence: true, inclusion: { in: YesNoAnswer.values }
      attribute field, :value_object, source: YesNoAnswer
    end

    def boolean_fields
      self.class::BOOLEAN_FIELDS
    end

    private

    def persist!
      application.update!(attributes_to_reset)
    end

    def attributes_to_reset
      attributes.merge(
        time_spent: preparation_time == YesNoAnswer::YES ? time_spent : nil
      )
    end
  end
end
