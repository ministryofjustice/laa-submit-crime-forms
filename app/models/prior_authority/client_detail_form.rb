module PriorAuthority
  class ClientDetailForm < PriorAuthorityApplication
    validates :client_first_name, presence: true
    validates :client_last_name, presence: true
    validates :client_date_of_birth, presence: true, multiparam_date: { allow_past: true, allow_future: false }

    def extended_update(attributes, skip_validation: false)
      if skip_validation
        assign_attributes(attributes)
        update(client_detail_form_status: :incomplete)
        save(validate: false)
        return true
      end

      return false unless update(attributes)

      update(client_detail_form_status: :complete)

      true
    end
  end
end
