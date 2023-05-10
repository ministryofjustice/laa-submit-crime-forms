module Tasks
  class GuiltyPlea < BaseTask
    def path
      edit_steps_guilty_plea_path
    end

    def not_applicable?
      false
    end

    def can_start?
      application.plea == Plea::GUILTY.value.to_s
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
