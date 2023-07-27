require 'steps/base_form_object'

module Steps
  class ClaimDetailsForm < Steps::BaseFormObject
    attr_writer :preparation_time, :work_before, :work_after

    VIEW_BOOLEAN_FIELDS = %i[supplemental_claim preparation_time work_before work_after].freeze

    attribute :prosecution_evidence, :integer
    attribute :defence_statement, :integer
    attribute :number_of_witnesses, :integer
    attribute :time_spent, :time_period
    attribute :work_before_date, :multiparam_date
    attribute :work_after_date, :multiparam_date
    attribute :supplemental_claim, :value_object, source: YesNoAnswer

    validates :prosecution_evidence, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :defence_statement, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :number_of_witnesses, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :time_spent, presence: true, time_period: true,
      if: -> { preparation_time == YesNoAnswer::YES }
    validates :work_before_date, presence: true, multiparam_date: { allow_past: true, allow_future: false },
      if: -> { work_before == YesNoAnswer::YES }
    validates :work_after_date, presence: true, multiparam_date: { allow_past: true, allow_future: false },
      if: -> { work_after == YesNoAnswer::YES }

    VIEW_BOOLEAN_FIELDS.each do |field|
      validates field, presence: true, inclusion: { in: YesNoAnswer.values }
    end

    def boolean_fields
      self.class::VIEW_BOOLEAN_FIELDS
    end

    def preparation_time
      return YesNoAnswer.new(@preparation_time) if @preparation_time.present?

      time_spent.present? ? YesNoAnswer::YES : nil
    end

    def work_before
      return YesNoAnswer.new(@work_before) if @work_before.present?

      work_before_date.present? ? YesNoAnswer::YES : nil
    end

    def work_after
      return YesNoAnswer.new(@work_after) if @work_after.present?

      work_after_date.present? ? YesNoAnswer::YES : nil
    end

    private

    def persist!
      application.update!(attributes_to_reset)
    end

    def attributes_to_reset
      attributes.merge(
        time_spent: preparation_time == YesNoAnswer::YES  ? time_spent : nil,
        work_before_date: work_before == YesNoAnswer::YES ? work_before_date : nil,
        work_after_date: work_after == YesNoAnswer::YES ? work_after_date : nil,
      )
    end
  end
end
