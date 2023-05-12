require 'steps/base_form_object'

module Steps
  class CaseDisposalForm < Steps::BaseFormObject
    attribute :plea, :value_object, source: PleaOptions
    validates :plea, presence: true, inclusion: { in: PleaOptions.values }

    PleaOptions.each_value do |plea|
      next unless plea.requires_date_field?

      attribute "#{plea.value}_date", :multiparam_date
      validates "#{plea.value}_date", presence: true,
              multiparam_date: { allow_past: true, allow_future: false },
              if: ->(obj) { obj.plea == plea }
    end

    def choices
      {
        guilty_pleas: PleaOptions::GUILTY_OPTIONS,
        not_guilty_pleas: PleaOptions::NOT_GUILTY_OPTIONS,
      }
    end

    private

    def persist!
      application.update!(attributes_with_resets)
    end

    # ensure we reset any date fields when not the plea
    def attributes_with_resets
      PleaOptions.values.each_with_object(attributes) do |plea_inst, result|
        next unless plea_inst.requires_date_field?
        next if plea_inst == plea

        result["#{plea_inst.value}_date"] = nil
      end
    end
  end
end
