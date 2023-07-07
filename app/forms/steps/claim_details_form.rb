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
      if: :preparation_time
    validates :work_before_date, presence: true, multiparam_date: { allow_past: true, allow_future: false },
      if: :work_before
    validates :work_after_date, presence: true, multiparam_date: { allow_past: true, allow_future: false },
      if: :work_after

    BOOLEAN_FIELDS.each do |field|
      validates field, presence: true, inclusion: { in: YesNoAnswer.values }
      attribute field, :value_object, source: YesNoAnswer
    end

    def boolean_fields
      self.class::VIEW_BOOLEAN_FIELDS
    end

    def preparation_time
      @preparation_time.nil? ? time_spent.present? : @preparation_time == 'yes'
    end

    def work_before
      @work_before.nil? ? work_before_date.present? : @work_before == 'yes'
    end

    def work_after
      @work_after.nil? ? work_after_date.present? : @work_after == 'yes'
    end

    private

    def persist!
      application.update!(attributes_to_reset)
    end

    def attributes_to_reset
      attributes.merge(
        time_spent: preparation_time  ? time_spent : nil,
        work_before_date: work_before ? work_before_date : nil,
        work_after_date: work_after ? work_after_date : nil,
      )
    end
  end
end
