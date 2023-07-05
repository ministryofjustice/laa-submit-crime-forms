require 'steps/base_form_object'

module Steps
  class HearingDetailsForm < Steps::BaseFormObject
    attribute :first_hearing_date, :multiparam_date
    attribute :number_of_hearing, :integer
    attribute :court, :string
    attribute :in_area, :value_object, source: YesNoAnswer
    attribute :youth_count, :value_object, source: YesNoAnswer
    attribute :hearing_outcome, :string
    attribute :matter_type, :string

    validates :first_hearing_date, presence: true,
            multiparam_date: { allow_past: true, allow_future: false }
    validates :number_of_hearing, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :court, presence: true
    validates :in_area, presence: true, inclusion: { in: YesNoAnswer.values }
    validates :youth_count, presence: true, inclusion: { in: YesNoAnswer.values }
    validates :hearing_outcome, presence: true
    validates :matter_type, presence: true

    def court_suggestion=(value)
      self.court = value
    end

    private

    def persist!
      application.update!(attributes)
    end
  end
end
