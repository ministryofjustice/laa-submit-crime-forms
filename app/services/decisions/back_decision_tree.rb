module Decisions
  class BackDecisionTree < DslDecisionTree
    # used to add custom methods to filter/query the data
    WRAPPER_CLASS = SimpleDelegator

    # start_page - takes use back to previous page
    from('steps/firm_details').goto(show: 'steps/start_page')
    from('steps/defendant_details')
      .when(-> { application.defendants.any? })
      .goto(edit: 'steps/defendant_summary')
      .goto(edit: 'steps/firm_details')
    from('steps/defendant_summary').goto(edit: 'steps/firm_details')
    from('steps/defendant_delete').goto(edit: 'steps/defendant_summary')
    from('steps/case_details').goto(edit: 'steps/defendant_summary')
    from('steps/hearing_details').goto(edit: 'steps/case_details')
    from('steps/case_disposal').goto(edit: 'steps/hearing_details')
    from('steps/reason_for_claim').goto(edit: 'steps/case_disposal')
    from('steps/claim_details').goto(edit: 'steps/reason_for_claim')
    from('steps/work_item')
      .when(-> { application.work_items.any? })
      .goto(edit: 'steps/work_items')
      .goto(edit: 'steps/claim_details')
    from('steps/work_items').goto(edit: 'steps/claim_details')
    from('steps/work_item_delete').goto(edit: 'steps/work_items')
    from('steps/letters_calls').goto(edit: 'steps/work_items')
    from('steps/disbursement_add').goto(edit: 'steps/letters_calls')
    from('steps/disbursement_type')
      .when(-> { application.disbursements.any? })
      .goto(edit: 'steps/disbursements')
      .goto(edit: 'steps/disbursement_add')
    from('steps/disbursement_cost')
      .goto(edit: 'steps/disbursement_type', disbursement_id: -> { record.id })
    from('steps/disbursements').goto(edit: 'steps/letters_calls')
    from('steps/disbursement_delete').goto(edit: 'steps/disbursements')
    from('steps/cost_summary')
      .when(-> { application.disbursements.any? })
      .goto(edit: 'steps/disbursements')
      .goto(edit: 'steps/disbursement_add')
    from('steps/other_info').goto(show: 'steps/cost_summary')
    from('steps/supporting_evidence').goto(edit: 'steps/other_info')
    from('steps/check_answers').goto(edit: 'steps/supporting_evidence')
    from('steps/equality').goto(show: 'steps/check_answers')
    from('steps/equality_questions').goto(edit: 'steps/equality')
    # TODO: we should be storing the answer to the ask equality question and use that in the decision
    from('steps/solicitor_declaration').goto(edit: 'steps/equality')
  end
end
