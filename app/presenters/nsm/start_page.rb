module Nsm
  module StartPage
    # This allows us to use the edit and update paths before the
    # associated record is fully saved.
    NEW_RECORD = '00000000-0000-0000-0000-000000000000'.freeze

    class PreTaskList < TaskList::Collection
      SECTIONS = [['nsm/what', ['nsm/claim_type']]].freeze
    end

    class TaskList < TaskList::Collection
      SECTIONS = [
        [
          'nsm/about_you', [
            'nsm/firm_details'
          ]
        ],
        [
          'nsm/defendant', [
            'nsm/defendants',
          ]
        ],
        [
          'nsm/case', [
            'nsm/case_details',
            'nsm/hearing_details',
            'nsm/case_disposal',
            # :nocov:
            FeatureFlags.youth_court_fee.enabled? ? ['nsm/case_category', 'nsm/case_outcome'] : nil
            # :nocov:
          ].compact.flatten
        ],
        [
          'nsm/claim', [
            'nsm/reason_for_claim',
            'nsm/claim_details',
            'nsm/work_items',
            'nsm/letters_calls',
            'nsm/disbursements',
            'nsm/cost_summary',
            'nsm/other_info'
          ]
        ],
        [
          'nsm/evidence', [
            'nsm/supporting_evidence'
          ]
        ],
        [
          'nsm/review', [
            'nsm/check_answers',
            'nsm/solicitor_declaration'
          ]
        ],
      ].freeze
    end
  end
end
