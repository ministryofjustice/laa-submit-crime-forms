require 'steps/base_form_object'

module Steps
  class CaseDetailsForm < Steps::BaseFormObject
    BOOLEAN_FIELDS = %i[assigned_counsel unassigned_counsel agent_instructed remitted_to_magistrate].freeze

    attribute :ufn, :string
    attribute :main_offence, :string
    attribute :main_offence_date, :multiparam_date
    attribute :assigned_counsel, :string
    attribute :unassigned_counsel, :string
    attribute :agent_instructed, :string
    attribute :remitted_to_magistrate, :string

    validates :ufn, presence: true
    validates :main_offence, presence: true
    validates :main_offence_date, presence: true,
         multiparam_date: { allow_past: true, allow_future: false }
    validates :assigned_counsel, presence: true
    validates :unassigned_counsel, presence: true
    validates :agent_instructed, presence: true
    validates :remitted_to_magistrate, presence: true

    BOOLEAN_FIELDS.each do |field|
      attribute field, :value_object, source: YesNoAnswer
      validates field, presence: true, inclusion: { in: YesNoAnswer.values }
    end

    def boolean_fields
      self.class::BOOLEAN_FIELDS
    end

    private

    def persist!
      application.update!(attributes)
    end
  end
end
