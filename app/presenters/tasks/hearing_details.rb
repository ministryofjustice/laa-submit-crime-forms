module Tasks
  class HearingDetails < BaseTask
    def path
      edit_steps_hearing_details_path
    end

    def not_applicable?
      false
    end

    def can_start?
      application.plea.present?
    end

    def completed?
      application.values_at(*hearing_details_fields).all?(&:present?)
    end

    private

    def hearing_details_fields
      Steps::HearingDetailsForm.attribute_names
    end
  end
end
