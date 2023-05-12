require 'steps/base_form_object'

module Steps
  class CaseDisposalForm < Steps::BaseFormObject
    attribute :plea, :value_object, source: PleaOptions
    validates :plea, presence: true, inclusion: { in: PleaOptions.values }

    PleaOptions.values.each do |plea|
      next unless plea.has_date_field?

      attribute "#{plea.value}_date", :multiparam_date
      validates "#{plea.value}_date", presence: true,
              multiparam_date: { allow_past: true, allow_future: false },
              if: -> (obj) { obj.plea == plea }
    end

    def choices
      {
        guilty_pleas: PleaOptions::GUILTY_OPTIONS,
        not_guilty_pleas: PleaOptions::NOT_GUILTY_OPTIONS,
      }
    end

    private

    def persist!
      application.update!(attributes)
    end
  end
end
