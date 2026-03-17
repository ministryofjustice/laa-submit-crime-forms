module Nsm
  module Steps
    class ClaimDetailsForm < ::Steps::BaseFormObject
      BOOLEAN_FIELDS = %i[preparation_time work_before work_after wasted_costs].freeze

      attribute :prosecution_evidence, :fully_validatable_integer
      attribute :defence_statement, :fully_validatable_integer
      attribute :number_of_witnesses, :fully_validatable_integer
      attribute :time_spent, :time_period
      attribute :work_before_date, :multiparam_date
      attribute :work_after_date, :multiparam_date
      attribute :work_completed_date, :multiparam_date

      validates :prosecution_evidence, presence: true, is_a_number: true,
        numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validate :prosecution_evidence_within_limit
      validates :defence_statement, presence: true, is_a_number: true,
        numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validate :defence_statement_within_limit
      validates :number_of_witnesses, presence: true, is_a_number: true,
        numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validate :number_of_witnesses_within_limit
      validates :time_spent, presence: true, time_period: true,
        if: -> { preparation_time == YesNoAnswer::YES }
      validate :time_spent_hours_within_limit, if: -> { preparation_time == YesNoAnswer::YES }
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

      def prosecution_evidence_within_limit
        return unless prosecution_evidence.present? && prosecution_evidence.is_a?(Numeric)
        return unless prosecution_evidence > NumericLimits::MAX_INTEGER

        errors.add(:prosecution_evidence, :less_than_or_equal_to, count: NumericLimits::MAX_INTEGER)
      end

      def defence_statement_within_limit
        return unless defence_statement.present? && defence_statement.is_a?(Numeric)
        return unless defence_statement > NumericLimits::MAX_INTEGER

        errors.add(:defence_statement, :less_than_or_equal_to, count: NumericLimits::MAX_INTEGER)
      end

      def number_of_witnesses_within_limit
        return unless number_of_witnesses.present? && number_of_witnesses.is_a?(Numeric)
        return unless number_of_witnesses > NumericLimits::MAX_INTEGER

        errors.add(:number_of_witnesses, :less_than_or_equal_to, count: NumericLimits::MAX_INTEGER)
      end

      def time_spent_hours_within_limit
        return unless time_spent.present? && !time_spent.is_a?(Hash) && time_spent.respond_to?(:hours)
        return unless time_spent.hours.to_i > NumericLimits::MAX_INTEGER

        errors.add(:time_spent, :max_hours, count: NumericLimits::MAX_INTEGER)
      end
    end
  end
end
