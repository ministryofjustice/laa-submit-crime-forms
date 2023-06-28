require 'steps/base_form_object'

module Steps
  class ClaimDetailsForm < Steps::BaseFormObject
    attr_writer :work_before, :work_after

    BOOLEAN_FIELDS = %i[supplemental_claim preparation_time].freeze

    VIEW_BOOLEAN_FIELDS = %i[supplemental_claim preparation_time work_before work_after].freeze

    attribute :prosecution_evidence, :string
    attribute :defence_statement, :string
    attribute :number_of_witnesses, :integer
    attribute :time_spent, :time_period
    attribute :work_before_date, :multiparam_date
    attribute :work_after_date, :multiparam_date

    validates :prosecution_evidence, presence: true
    validates :defence_statement, presence: true
    validates :number_of_witnesses, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :time_spent, numericality: { only_integer: true, greater_than: 0 }, time_period: true,
        if: ->(form) { form.preparation_time == YesNoAnswer::YES }
    validates :work_before_date, presence: true, multiparam_date: { allow_past: true, allow_future: false },
        if: ->(form) { form.work_before_date}
    validates :work_after_date, presence: true, multiparam_date: { allow_past: true, allow_future: false },
        if: ->(form) { form.work_after_date}

    BOOLEAN_FIELDS.each do |field|
      validates field, presence: true, inclusion: { in: YesNoAnswer.values }
      attribute field, :value_object, source: YesNoAnswer
    end

    def boolean_fields
      self.class::VIEW_BOOLEAN_FIELDS
    end

    # state hasnt been set yet and of no use validate on save
    def work_before?
      true
    end

    def work_before
      true
    end

    def work_after?
      true
    end

    def work_after
      true
    end

    private

    def persist!
      application.update!(attributes_to_reset)
    end

    def attributes_to_reset
      # @work_before and @work_after now set so use on final save -prevents saving if uses sets date
      # and then decides radio box should be no
      attributes.merge(
        time_spent: preparation_time == YesNoAnswer::YES ? time_spent : nil,
        work_before_date: @work_before == "yes" ? work_before_date : nil,
        work_after_date: @work_after == "yes" ? work_after_date : nil,
       )
    end
  end
end
