module PriorAuthority
  module StartPage
    class PreTaskList < TaskList::Collection
      SECTIONS = [
        [:application_detail, ['prior_authority/ufn']],
      ].freeze
    end

    class TaskList < TaskList::Collection
      SECTIONS = [
        [
          :case_contact, [
            'prior_authority/case_contact'
          ],
        ],
        [
          :about_case, [
            'prior_authority/client_detail',
            'prior_authority/case_hearing_detail'
          ],
        ],
        [
          :primary_quote, [
            'prior_authority/primary_quote'
          ],
        ],
      ].freeze
    end
  end
end
