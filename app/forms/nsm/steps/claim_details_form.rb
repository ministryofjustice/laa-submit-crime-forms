module Nsm
  module Steps
    class ClaimDetailsForm < ::Steps::BaseFormObject
      BOOLEAN_FIELDS = %i[supplemental_claim preparation_time work_before work_after wasted_costs].freeze

      attribute :prosecution_evidence, :fully_validatable_integer
      attribute :defence_statement, :fully_validatable_integer
      attribute :number_of_witnesses, :fully_validatable_integer
      attribute :time_spent, :time_period
      attribute :work_before_date, :multiparam_date
      attribute :work_after_date, :multiparam_date
      attribute :work_completed_date, :multiparam_date

      validates :prosecution_evidence, presence: true, is_a_number: true,
numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :defence_statement, presence: true, is_a_number: true,
numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :number_of_witnesses, presence: true, is_a_number: true,
numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :time_spent, presence: true, time_period: true,
        if: -> { preparation_time == YesNoAnswer::YES }
      validates :work_before_date, presence: true, multiparam_date: { allow_past: true, allow_future: false },
        if: -> { work_before == YesNoAnswer::YES }
      validates :work_after_date, presence: true, multiparam_date: { allow_past: true, allow_future: false },
        if: -> { work_after == YesNoAnswer::YES }
      validates :work_completed_date, presence: true, multiparam_date: { allow_past: true, allow_future: false }

      BOOLEAN_FIELDS.each do |field|
        attribute field, :value_object, source: YesNoAnswer
        validates field, presence: true, inclusion: { in: YesNoAnswer.values }
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
          time_spent: preparation_time == YesNoAnswer::YES  ? time_spent : nil,
          work_before_date: work_before == YesNoAnswer::YES ? work_before_date : nil,
          work_after_date: work_after == YesNoAnswer::YES ? work_after_date : nil,
        )
      end
    end
  end
end
