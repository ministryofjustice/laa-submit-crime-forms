module Nsm
  module Steps
    class HearingDetailsForm < ::Steps::BaseFormObject
      attribute :first_hearing_date, :multiparam_date
      attribute :number_of_hearing, :fully_validatable_integer
      attribute :court, :string
      attribute :youth_court, :value_object, source: YesNoAnswer
      attribute :hearing_outcome, :string
      attribute :matter_type, :string

      validates :first_hearing_date, presence: true,
              multiparam_date: { allow_past: true, allow_future: false }
      validates :number_of_hearing, presence: true, is_a_number: true,
        numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: NumericLimits::MAX_INTEGER }
      validates :court, presence: true
      validates :youth_court, presence: true, inclusion: { in: YesNoAnswer.values }
      validates :hearing_outcome, presence: true
      validates :matter_type, presence: true

      def court_suggestion=(value)
        self.court = if !value.in?(LaaCrimeFormsCommon::Court.all.map(&:name)) && court != value
                       "#{value} - n/a"
                     else
                       value
                     end
      end

      def should_reset_youth_court_fields?
        youth_court == YesNoAnswer::NO
      end

      private

      def persist!
        application.update!(attributes.merge(attributes_to_reset))
      end

      def attributes_to_reset
        {
          'include_youth_court_fee' => should_reset_youth_court_fields? ? nil : application.include_youth_court_fee,
        }
      end
    end
  end
end
