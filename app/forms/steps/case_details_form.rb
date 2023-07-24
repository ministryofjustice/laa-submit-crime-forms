require 'steps/base_form_object'

module Steps
  class CaseDetailsForm < Steps::BaseFormObject
    BOOLEAN_FIELDS = %i[assigned_counsel unassigned_counsel agent_instructed remitted_to_magistrate].freeze

    attribute :main_offence, :string
    attribute :main_offence_date, :multiparam_date

    attribute :remitted_to_magistrate, :string
    attribute :remitted_to_magistrate_date, :multiparam_date

    validates :main_offence, presence: true
    validates :main_offence_date, presence: true,
         multiparam_date: { allow_past: true, allow_future: false }
 
    validates :remitted_to_magistrate_date, presence: true, multiparam_date: { allow_past: true, allow_future: false },
      if: :remitted_to_magistrate?
       
    BOOLEAN_FIELDS.each do |field|
      attribute field, :value_object, source: YesNoAnswer
      validates field, presence: true, inclusion: { in: YesNoAnswer.values }
    end

    def boolean_fields
      self.class::BOOLEAN_FIELDS
    end

    def main_offence_suggestion=(value)
      self.main_offence = value
    end

    def remitted_to_magistrate?
      self.remitted_to_magistrate== YesNoAnswer::YES
    end

    private

    def persist!
      application.update!(attributes)
    end
  end
end
