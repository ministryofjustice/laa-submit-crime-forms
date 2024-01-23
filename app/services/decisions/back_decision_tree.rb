module Decisions
  class BackDecisionTree < DslDecisionTree
    # used to add custom methods to filter/query the data
    WRAPPER_CLASS = SimpleDelegator

    # start_page - takes use back to previous page
    from('nsm/steps/start_page').goto(edit: 'nsm/steps/claim_type')
    from('nsm/steps/firm_details').goto(show: 'nsm/steps/start_page')
    from('nsm/steps/defendant_details')
      .when(-> { application.defendants.exists? })
      .goto(edit: 'nsm/steps/defendant_summary')
      .goto(edit: 'nsm/steps/firm_details')
    from('nsm/steps/defendant_summary').goto(edit: 'nsm/steps/firm_details')
    from('nsm/steps/defendant_delete').goto(edit: 'nsm/steps/defendant_summary')
    from('nsm/steps/case_details').goto(edit: 'nsm/steps/defendant_summary')
    from('nsm/steps/hearing_details').goto(edit: 'nsm/steps/case_details')
    from('nsm/steps/case_disposal').goto(edit: 'nsm/steps/hearing_details')
    from('nsm/steps/reason_for_claim').goto(edit: 'nsm/steps/case_disposal')
    from('nsm/steps/claim_details').goto(edit: 'nsm/steps/reason_for_claim')
    from('nsm/steps/work_item')
      .when(-> { application.work_items.exists? })
      .goto(edit: 'nsm/steps/work_items')
      .goto(edit: 'nsm/steps/claim_details')
    from('nsm/steps/work_items').goto(edit: 'nsm/steps/claim_details')
    from('nsm/steps/work_item_delete').goto(edit: 'nsm/steps/work_items')
    from('nsm/steps/letters_calls')
      .when(-> { application.work_items.exists? })
      .goto(edit: 'nsm/steps/work_items')
      .goto(edit: 'nsm/steps/work_item', work_item_id: StartPage::NEW_RECORD)
    from('nsm/steps/disbursement_add').goto(edit: 'nsm/steps/letters_calls')
    from('nsm/steps/disbursement_type')
      .when(-> { application.disbursements.exists? })
      .goto(edit: 'nsm/steps/disbursements')
      .goto(edit: 'nsm/steps/disbursement_add')
    from('nsm/steps/disbursement_cost')
      .goto(edit: 'nsm/steps/disbursement_type', disbursement_id: -> { record.id })
    from('nsm/steps/disbursements').goto(edit: 'nsm/steps/letters_calls')
    from('nsm/steps/disbursement_delete').goto(edit: 'nsm/steps/disbursements')
    from('nsm/steps/cost_summary')
      .when(-> { application.disbursements.exists? })
      .goto(edit: 'nsm/steps/disbursements')
      .goto(edit: 'nsm/steps/disbursement_add')
    from('nsm/steps/other_info').goto(show: 'nsm/steps/cost_summary')
    from('nsm/steps/supporting_evidence').goto(edit: 'nsm/steps/other_info')
    from('nsm/steps/check_answers').goto(edit: 'nsm/steps/supporting_evidence')
    from('nsm/steps/equality').goto(show: 'nsm/steps/check_answers')
    from('nsm/steps/equality_questions').goto(edit: 'nsm/steps/equality')
    # TODO: we should be storing the answer to the ask equality question and use that in the decision
    from('nsm/steps/solicitor_declaration').goto(edit: 'nsm/steps/equality')

    # prior authority steps
    from('prior_authority/steps/prison_law').goto(edit: 'prior_authority/applications')
    from('prior_authority/steps/authority_value').goto(edit: 'prior_authority/steps/prison_law')
    from('prior_authority/steps/ufn').goto(edit: 'prior_authority/steps/authority_value')
    from('prior_authority/steps/case_contact').goto(show: 'prior_authority/steps/start_page')
    from('prior_authority/steps/client_detail').goto(edit: 'prior_authority/steps/case_contact')
  end
end
