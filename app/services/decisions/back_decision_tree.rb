module Decisions
  class BackDecisionTree < BaseDecisionTree
    # used to add custom methods to filter/query the data
    WRAPPER_CLASS = CustomWrapper

    # start_page - takes use back to previous page
    from(DecisionTree::NSM_OFFICE_CODE).goto(edit: DecisionTree::NSM_CLAIM_TYPE)
    from(DecisionTree::NSM_OFFICE_AREA)
      .when(-> { application.submitter.multiple_offices? })
      .goto(edit: DecisionTree::NSM_OFFICE_CODE)
      .goto(edit: DecisionTree::NSM_CLAIM_TYPE)
    from(DecisionTree::NSM_COURT_AREA).goto(edit: DecisionTree::NSM_OFFICE_AREA)
    from(DecisionTree::NSM_CASE_TRANSFER).goto(edit: DecisionTree::NSM_COURT_AREA)

    from(DecisionTree::NSM_FIRM_DETAILS).goto(show: DecisionTree::NSM_START_PAGE)
    from(DecisionTree::NSM_CONTACT_DETAILS).goto(edit: DecisionTree::NSM_FIRM_DETAILS)
    from('nsm/steps/defendant_details')
      .when(-> { application.defendants.exists? })
      .goto(edit: DecisionTree::NSM_DEFENDANT_SUMMARY)
      .goto(edit: DecisionTree::NSM_CONTACT_DETAILS)
    from(DecisionTree::NSM_DEFENDANT_SUMMARY).goto(edit: DecisionTree::NSM_CONTACT_DETAILS)
    from('nsm/steps/defendant_delete').goto(edit: DecisionTree::NSM_DEFENDANT_SUMMARY)
    from('nsm/steps/case_details').goto(edit: DecisionTree::NSM_DEFENDANT_SUMMARY)
    from('nsm/steps/hearing_details').goto(edit: 'nsm/steps/case_details')
    from(DecisionTree::NSM_CASE_CATEGORY).goto(edit: 'nsm/steps/hearing_details')
    from(DecisionTree::NSM_CASE_OUTCOME).goto(edit: DecisionTree::NSM_CASE_CATEGORY)
    from(DecisionTree::NSM_YCF_FEE).goto(edit: DecisionTree::NSM_CASE_OUTCOME)
    from('nsm/steps/case_disposal').goto(edit: 'nsm/steps/hearing_details')
    from('nsm/steps/reason_for_claim')
      .when(-> { application.can_claim_youth_court? })
      .goto(edit: DecisionTree::NSM_YCF_FEE)
      .when(-> { application.after_youth_court_cutoff? })
      .goto(edit: DecisionTree::NSM_CASE_OUTCOME)
      .goto(edit: 'nsm/steps/case_disposal')

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

    # further information
    from('nsm/steps/further_information').goto(show: 'nsm/steps/view_claim', id: -> { application.id })
    from('nsm/steps/rfi_solicitor_declaration').goto(edit: 'nsm/steps/further_information')
    # ---------------------------------
    # prior authority application steps
    # ---------------------------------
    from('prior_authority/steps/prison_law').goto(edit: 'prior_authority/applications')
    from('prior_authority/steps/authority_value').goto(edit: 'prior_authority/steps/prison_law')
    from('prior_authority/steps/ufn')
      .when(-> { application.pre_draft? })
      .goto(edit: 'prior_authority/steps/authority_value')
      .goto { overwrite_to_cya }

    from('prior_authority/steps/case_contact').goto { overwrite_to_cya }
    from('prior_authority/steps/client_detail').goto { overwrite_to_cya }

    # prison law flow
    from('prior_authority/steps/next_hearing').goto { overwrite_to_cya }

    # non-prison law flow
    from('prior_authority/steps/case_detail').goto { overwrite_to_cya }
    from('prior_authority/steps/hearing_detail')
      .goto { overwrite_to_cya(action: :edit, destination: 'prior_authority/steps/case_detail') }
    from('prior_authority/steps/youth_court').goto(edit: 'prior_authority/steps/hearing_detail')
    from('prior_authority/steps/psychiatric_liaison').goto(edit: 'prior_authority/steps/hearing_detail')

    # primary quote
    from('prior_authority/steps/primary_quote').goto { overwrite_to_cya }
    from('prior_authority/steps/service_cost').goto(edit: 'prior_authority/steps/primary_quote')
    from(DecisionTree::PRIOR_AUTHORITY_PRIMARY_QUOTE_SUMMARY).goto(edit: 'prior_authority/steps/service_cost')
    from('prior_authority/steps/reason_why').goto { overwrite_to_cya }
    from('prior_authority/steps/travel_detail').goto(show: DecisionTree::PRIOR_AUTHORITY_PRIMARY_QUOTE_SUMMARY)
    from('prior_authority/steps/delete_travel').goto(show: DecisionTree::PRIOR_AUTHORITY_PRIMARY_QUOTE_SUMMARY)
    from('prior_authority/steps/additional_costs').goto(show: DecisionTree::PRIOR_AUTHORITY_PRIMARY_QUOTE_SUMMARY)
    from('prior_authority/steps/additional_cost_details')
      .goto(show: DecisionTree::PRIOR_AUTHORITY_PRIMARY_QUOTE_SUMMARY)

    # additional quotes
    from(DecisionTree::PRIOR_AUTHORITY_ALTERNATIVE_QUOTES).goto { overwrite_to_cya }
    from('prior_authority/steps/alternative_quote_details')
      .goto(edit: DecisionTree::PRIOR_AUTHORITY_ALTERNATIVE_QUOTES)

    # check answers
    from('prior_authority/steps/check_answers')
      .when(-> { application.sent_back? })
      .goto(show: '/prior_authority/applications', id: -> { application.id })
      .goto(show: 'prior_authority/steps/start_page')

    # further information
    # We can't use overwrite_to_cya here because in a sent_back loop there will already be
    # check answers in the navigation stack whether we've just come from there or not
    from('prior_authority/steps/further_information').goto(show: '/prior_authority/applications', id: -> { application.id })
  end
end
