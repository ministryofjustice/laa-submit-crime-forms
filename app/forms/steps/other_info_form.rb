require 'steps/base_form_object'

module Steps
  class OtherInfoForm < Steps::BaseFormObject
    BOOLEAN_FIELDS = %i[concluded].freeze

    attribute :other_info, :string
    attribute :conclusion, :string

    validates :other_info, presence: true
    validates :conclusion, presence: true,
      if: ->(form) { form.concluded == YesNoAnswer::YES }

    BOOLEAN_FIELDS.each do |field|
      validates field, presence: true, inclusion: { in: YesNoAnswer.values }
      attribute field, :value_object, source: YesNoAnswer
    end

    def boolean_fields
      self.class::BOOLEAN_FIELDS
    end

    private

    def persist!
      application.update!(attributes)
    end
  end
end
