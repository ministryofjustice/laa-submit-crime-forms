require 'steps/base_form_object'

module Steps
  class ClaimDetailsForm < Steps::BaseFormObject
    attr_writer :preparation_time, :work_before, :work_after

    BOOLEAN_FIELDS = %i[supplemental_claim].freeze

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
      if: -> { @preparation_time == YesNoAnswer::YES.to_s }
    validates :work_before_date, presence: true, multiparam_date: { allow_past: true, allow_future: false },
      if: -> { @work_before == YesNoAnswer::YES.to_s }
    validates :work_after_date, presence: true, multiparam_date: { allow_past: true, allow_future: false },
      if: -> { @work_after == YesNoAnswer::YES.to_s }

    BOOLEAN_FIELDS.each do |field|
      validates field, presence: true, inclusion: { in: YesNoAnswer.values }
      attribute field, :value_object, source: YesNoAnswer
    end

    def boolean_fields
      self.class::VIEW_BOOLEAN_FIELDS
    end

    # state hasnt been set yet so nil and of no use validate on save
    # the save only populates @preparation_time and @work_before and @work_after to yes or no
    # depending on the choice
    def preparation_time; end

    def work_before; end

    def work_after; end

    private

    def persist!
      application.update!(attributes_to_reset)
    end

    def attributes_to_reset
      # @preparation_time, @work_before and @work_after now set so use on final save -prevents saving if uses sets date
      # and then decides radio box should be no
      attributes.merge(
        time_spent: @preparation_time == YesNoAnswer::YES.to_s ? time_spent : nil,
        work_before_date: @work_before == YesNoAnswer::YES.to_s ? work_before_date : nil,
        work_after_date: @work_after == YesNoAnswer::YES.to_s ? work_after_date : nil,
      )
    end
  end
end
