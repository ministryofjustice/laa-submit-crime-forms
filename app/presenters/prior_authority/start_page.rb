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
          :contact_details, [
            'prior_authority/case_contact'
          ],
        ],
        [
          :about_case, [
            'prior_authority/client_detail',
            'prior_authority/case_and_hearing_detail',
          ],
        ],
        [
          :about_request, [
            :why_prior_authority
          ]
        ]
      ].freeze
    end
  end
end
