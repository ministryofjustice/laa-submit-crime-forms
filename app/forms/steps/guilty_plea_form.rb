require 'steps/base_form_object'

module Steps
  class GuiltyPleaForm < Steps::BaseFormObject
    attribute :guilty_pleas

    GuiltyPlea.values.each do |plea|
      next unless plea.has_date_field?

      attribute "#{plea.value}_date", :multiparam_date
      validates "#{plea.value}_date", presence: true,
              multiparam_date: { allow_past: true, allow_future: false },
              if: -> (obj) { obj.guilty_please.include?(plea.value.to_s) }
    end

    validates :guilty_pleas, presence: true

    private

    def persist!
      application.update(attributes)
    end
  end
end
