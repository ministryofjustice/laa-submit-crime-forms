module Tasks
  class FirmDetails < BaseTask
    def path
      edit_steps_firm_details_path
    end

    def not_applicable?
      false
    end

    def can_start?
      true
    end

    def in_progress?
      application.solicitor.present?
    end

    def completed?
      [
        application.solicitor.values_at(
          *Steps::FirmDetails::SolicitorForm.attribute_names
        ).all?(&:present?),
        application.firm_office.values_at(
          *Steps::FirmDetails::FirmOfficeForm.attribute_names
        ).all?(&:present?)
      ].all?
    end
  end
end
