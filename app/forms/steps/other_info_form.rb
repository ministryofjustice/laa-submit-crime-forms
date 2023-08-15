require 'steps/base_form_object'

module Steps
  class OtherInfoForm < Steps::BaseFormObject
    BOOLEAN_FIELDS = %i[is_other_info concluded].freeze

    attribute :other_info, :string
    attribute :conclusion, :string

    validates :other_info, presence: true,
    if: ->(form) { form.is_other_info == YesNoAnswer::YES }
    validates :conclusion, presence: true,
      if: ->(form) { form.concluded == YesNoAnswer::YES }

    BOOLEAN_FIELDS.each do |field|
      attribute field, :value_object, source: YesNoAnswer
      validates field, presence: true, inclusion: { in: YesNoAnswer.values }
    end

    def boolean_fields
      self.class::BOOLEAN_FIELDS
    end

    private

    def persist!
      attributes['conclusion'].clear if attributes['concluded'] == YesNoAnswer::NO
      attributes['other_info'].clear if attributes['is_other_info'] == YesNoAnswer::NO
      application.update!(attributes)
    end
  end
end
