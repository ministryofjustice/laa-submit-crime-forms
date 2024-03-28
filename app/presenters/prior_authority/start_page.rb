module PriorAuthority
  module StartPage
    class PreTaskList < TaskList::Collection
      SECTIONS = [
        [
          'prior_authority/application_detail', [
            'prior_authority/ufn'
          ]
        ],
      ].freeze
    end

    class FurtherInformationTaskList < TaskList::Collection
      SECTIONS = [
        [
          'prior_authority/contact_details', [
            'prior_authority/case_contact'
          ],
        ],
        [
          'prior_authority/about_case', [
            'prior_authority/client_detail',
            'prior_authority/case_and_hearing_detail',
          ],
        ],
        [
          'prior_authority/about_request', [
            'prior_authority/primary_quote',
            'prior_authority/alternative_quotes',
            'prior_authority/reason_why',
          ],
        ],
        [
          'prior_authority/review', [
            'prior_authority/further_information',
            'prior_authority/check_answers',
          ]
        ],
      ].freeze
    end

    class TaskList < TaskList::Collection
      SECTIONS = [
        [
          'prior_authority/contact_details', [
            'prior_authority/case_contact'
          ],
        ],
        [
          'prior_authority/about_case', [
            'prior_authority/client_detail',
            'prior_authority/case_and_hearing_detail',
          ],
        ],
        [
          'prior_authority/about_request', [
            'prior_authority/primary_quote',
            'prior_authority/alternative_quotes',
            'prior_authority/reason_why'
          ],
        ],
        [
          'prior_authority/review', [
            'prior_authority/check_answers',
          ]
        ],
      ].freeze
    end
  end
end
