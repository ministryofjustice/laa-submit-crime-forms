module PriorAuthority
  class CaseContactForm < PriorAuthorityApplication
    validates :contact_name, presence: true
    validates :contact_email, presence: true
    validates :firm_name, presence: true
    validates :firm_account_number, presence: true

    def extended_update(attributes, skip_validation: false)
      if skip_validation
        assign_attributes(attributes)
        update(case_contact_form_status: :incomplete)
        save(validate: false)
        return true
      end

      return false unless update(attributes)

      update(case_contact_form_status: :complete)

      true
    end
  end
end
