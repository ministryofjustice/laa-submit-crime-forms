module Decisions
  class BackDecisionTree < DslDecisionTree
    # used to add custom methods to filter/query the data
    WRAPPER_CLASS = SimpleDelegator

    # start_page - takes use back to previous page
    from('nsm/steps/start_page').goto(edit: 'nsm/steps/claim_type')
    from(DecisionTree::NSM_FIRM_DETAILS).goto(show: 'nsm/steps/start_page')
    from('nsm/steps/defendant_details')
      .when(-> { application.defendants.exists? })
      .goto(edit: DecisionTree::NSM_DEFENDANT_SUMMARY)
      .goto(edit: DecisionTree::NSM_FIRM_DETAILS)
    from(DecisionTree::NSM_DEFENDANT_SUMMARY).goto(edit: DecisionTree::NSM_FIRM_DETAILS)
    from('nsm/steps/defendant_delete').goto(edit: DecisionTree::NSM_DEFENDANT_SUMMARY)
    from('nsm/steps/case_details').goto(edit: DecisionTree::NSM_DEFENDANT_SUMMARY)
    from('nsm/steps/hearing_details').goto(edit: 'nsm/steps/case_details')
    from('nsm/steps/case_disposal').goto(edit: 'nsm/steps/hearing_details')
    from('nsm/steps/reason_for_claim').goto(edit: 'nsm/steps/case_disposal')
    from(DecisionTree::NSM_CLAIM_DETAILS).goto(edit: 'nsm/steps/reason_for_claim')
    from(DecisionTree::NSM_WORK_ITEM)
      .when(-> { application.work_items.exists? })
      .goto(edit: DecisionTree::NSM_WORK_ITEMS)
      .goto(edit: DecisionTree::NSM_CLAIM_DETAILS)
    from(DecisionTree::NSM_WORK_ITEMS).goto(edit: DecisionTree::NSM_CLAIM_DETAILS)
    from('nsm/steps/work_item_delete').goto(edit: DecisionTree::NSM_WORK_ITEMS)
    from(DecisionTree::NSM_LETTERS_CALLS)
      .when(-> { application.work_items.exists? })
      .goto(edit: DecisionTree::NSM_WORK_ITEMS)
      .goto(edit: DecisionTree::NSM_WORK_ITEM, work_item_id: Nsm::StartPage::NEW_RECORD)
    from(DecisionTree::NSM_DISBURSEMENT_ADD).goto(edit: DecisionTree::NSM_LETTERS_CALLS)
    from(DecisionTree::NSM_DISBURSEMENT_TYPE)
      .when(-> { application.disbursements.exists? })
      .goto(edit: DecisionTree::NSM_DISBURSEMENTS)
      .goto(edit: DecisionTree::NSM_DISBURSEMENT_ADD)
    from('nsm/steps/disbursement_cost')
      .goto(edit: DecisionTree::NSM_DISBURSEMENT_TYPE, disbursement_id: -> { record.id })
    from(DecisionTree::NSM_DISBURSEMENTS).goto(edit: DecisionTree::NSM_LETTERS_CALLS)
    from('nsm/steps/disbursement_delete').goto(edit: DecisionTree::NSM_DISBURSEMENTS)
    from('nsm/steps/cost_summary')
      .when(-> { application.disbursements.exists? })
      .goto(edit: DecisionTree::NSM_DISBURSEMENTS)
      .goto(edit: DecisionTree::NSM_DISBURSEMENT_ADD)
    from('nsm/steps/other_info').goto(show: 'nsm/steps/cost_summary')
    from('nsm/steps/supporting_evidence').goto(edit: 'nsm/steps/other_info')
    from('nsm/steps/check_answers').goto(edit: 'nsm/steps/supporting_evidence')
    from(DecisionTree::NSM_EQUALITY).goto(show: 'nsm/steps/check_answers')
    from('nsm/steps/equality_questions').goto(edit: DecisionTree::NSM_EQUALITY)
    # TODO: we should be storing the answer to the ask equality question and use that in the decision
    from('nsm/steps/solicitor_declaration').goto(edit: DecisionTree::NSM_EQUALITY)

    # ---------------------------------
    # prior authority application steps
    # ---------------------------------
    from('prior_authority/steps/prison_law').goto(edit: 'prior_authority/applications')
    from('prior_authority/steps/authority_value').goto(edit: 'prior_authority/steps/prison_law')
    from('prior_authority/steps/ufn').goto(edit: 'prior_authority/steps/authority_value')
    from('prior_authority/steps/case_contact').goto(show: DecisionTree::PRIOR_AUTHORITY_START_PAGE)
    from('prior_authority/steps/client_detail').goto(edit: 'prior_authority/steps/case_contact')

    # prison law flow
    from('prior_authority/steps/next_hearing').goto(show: DecisionTree::PRIOR_AUTHORITY_START_PAGE)

    # non-prison law flow
    from('prior_authority/steps/case_detail').goto(edit: 'prior_authority/steps/client_detail')
    from('prior_authority/steps/hearing_detail').goto(edit: 'prior_authority/steps/case_detail')
    from('prior_authority/steps/youth_court').goto(edit: 'prior_authority/steps/hearing_detail')
    from('prior_authority/steps/psychiatric_liaison').goto(edit: 'prior_authority/steps/hearing_detail')

    from('prior_authority/steps/primary_quote').goto(show: DecisionTree::PRIOR_AUTHORITY_START_PAGE)
    from('prior_authority/steps/service_cost').goto(edit: 'prior_authority/steps/primary_quote')
    from('prior_authority/steps/primary_quote_summary').goto(edit: 'prior_authority/steps/service_cost')
    from('prior_authority/steps/reason_why').goto(show: DecisionTree::PRIOR_AUTHORITY_START_PAGE)
    from('prior_authority/steps/travel_detail').goto(show: DecisionTree::PRIOR_AUTHORITY_PRIMARY_QUOTE_SUMMARY)
    from('prior_authority/steps/delete_travel').goto(show: DecisionTree::PRIOR_AUTHORITY_PRIMARY_QUOTE_SUMMARY)
    from('prior_authority/steps/travel_detail').goto(edit: 'prior_authority/steps/travel')

    from('prior_authority/steps/additional_costs').goto(show: DecisionTree::PRIOR_AUTHORITY_PRIMARY_QUOTE_SUMMARY)
    from('prior_authority/steps/additional_cost_details')
      .goto(show: DecisionTree::PRIOR_AUTHORITY_PRIMARY_QUOTE_SUMMARY)
  end
end
