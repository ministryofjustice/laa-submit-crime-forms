module PriorAuthority
  module StartPage
    # This allows us to use the edit and update paths before the
    # associated record is fully saved.
    NEW_RECORD = '00000000-0000-0000-0000-000000000000'.freeze

    class PreTaskList < TaskList::Collection
      SECTIONS = [
        [:application_detail, [:prior_authority_ufn]],
      ].freeze
    end

    class TaskList < TaskList::Collection
      SECTIONS = [
        [
          :case_contact, [
            :prior_authority_case_contact
          ],
        ],
        [
          :about_case, [
            :prior_authority_client_detail,
            :prior_authority_case_hearing_detail
          ],
        ],
      ].freeze
    end
  end
end
