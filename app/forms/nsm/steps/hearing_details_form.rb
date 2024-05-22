module Nsm
  module Steps
    class HearingDetailsForm < ::Steps::BaseFormObject
      attribute :first_hearing_date, :multiparam_date
      attribute :number_of_hearing, :integer
      attribute :court, :string
      attribute :in_area, :value_object, source: YesNoAnswer
      attribute :youth_court, :value_object, source: YesNoAnswer
      attribute :hearing_outcome, :string
      attribute :matter_type, :string

      validates :first_hearing_date, presence: true,
              multiparam_date: { allow_past: true, allow_future: false }
      validates :number_of_hearing, presence: true, numericality: { only_integer: true, greater_than: 0 }
      validates :court, presence: true
      validates :in_area, presence: true, inclusion: { in: YesNoAnswer.values }
      validates :youth_court, presence: true, inclusion: { in: YesNoAnswer.values }
      validates :hearing_outcome, presence: true
      validates :matter_type, presence: true

      def court_suggestion=(value)
        self.court = if !value.in?(LaaMultiStepForms::Court.all.map(&:name)) && court != value
                       "#{value} - n/a"
                     else
                       value
                     end
      end

      private

      def persist!
        application.update!(attributes)
      end
    end
  end
end
