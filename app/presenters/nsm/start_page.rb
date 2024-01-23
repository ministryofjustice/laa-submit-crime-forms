module Nsm
  module StartPage
    # This allows us to use the edit and update paths before the
    # associated record is fully saved.
    NEW_RECORD = '00000000-0000-0000-0000-000000000000'.freeze

    class PreTaskList < TaskList::Collection
      SECTIONS = [[:what, [->(app) { "claim_type.#{app.claim_type}" }]]].freeze
    end

    class TaskList < TaskList::Collection
      SECTIONS = [
        [:about_you, ['nsm/firm_details']],
        [:defendant, ['nsm/defendants',]],
        [:case, ['nsm/case_details', 'nsm/hearing_details', 'nsm/case_disposal']],
        [:claim,
         ['nsm/reason_for_claim',
          'nsm/claim_details',
          'nsm/work_items',
          'nsm/letters_calls',
          'nsm/disbursements',
          'nsm/cost_summary',
          'nsm/other_info']],
        [:evidence, ['nsm/supporting_evidence']],
        [:review,
         ['nsm/check_answers', 'nsm/solicitor_declaration']],
      ].freeze
    end
  end
end
