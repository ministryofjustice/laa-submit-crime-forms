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

    def completed?
      [
        application.firm_office.values_at(*firm_office_fields).all?(&:present?),
        application.solicitor.values_at(*solicitor_fields).all?(&:present?),
      ].all?
    end

    private

    def solicitor_fields
      Steps::FirmDetails::SolicitorForm.attribute_names - %w[contact_full_name contact_email]
    end

    def firm_office_fields
      Steps::FirmDetails::FirmOfficeForm.attribute_names - %w[address_line_2]
    end
  end
end
