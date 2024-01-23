module Decisions
  class DecisionTree < DslDecisionTree
    # used to add custom methods to filter/query the data
    WRAPPER_CLASS = CustomWrapper

    from(:claim_type).goto(show: 'nsm/steps/start_page')
    # start_page to firm_details is a hard coded link as show page
    from(:firm_details)
      .when(-> { application.defendants.none? })
      .goto(edit: 'nsm/steps/defendant_details', defendant_id: Nsm::StartPage::NEW_RECORD)
      .goto(edit: 'nsm/steps/defendant_summary')
    from(:defendant_details).goto(edit: 'nsm/steps/defendant_summary')
    from(:defendant_delete).goto(edit: 'nsm/steps/defendant_summary')
    from(:defendant_summary)
      .when(-> { add_another.yes? })
      .goto(edit: 'nsm/steps/defendant_details', defendant_id: Nsm::StartPage::NEW_RECORD)
      .when(-> { any_invalid?(application.defendants, Nsm::Steps::DefendantDetailsForm) })
      .goto(edit: 'nsm/steps/defendant_summary')
      .goto(edit: 'nsm/steps/case_details')
    from(:case_details).goto(edit: 'nsm/steps/hearing_details')
    from(:hearing_details).goto(edit: 'nsm/steps/case_disposal')
    from(:case_disposal).goto(edit: 'nsm/steps/reason_for_claim')
    from(:reason_for_claim).goto(edit: 'nsm/steps/claim_details')
    from(:claim_details)
      .when(-> { application.work_items.none? })
      .goto(edit: 'nsm/steps/work_item', work_item_id: Nsm::StartPage::NEW_RECORD)
      .goto(edit: 'nsm/steps/work_items')
    from(:work_item).goto(edit: 'nsm/steps/work_items')
    from(:work_item_delete)
      .when(-> { application.work_items.none? })
      .goto(edit: 'nsm/steps/work_item', work_item_id: Nsm::StartPage::NEW_RECORD)
      .goto(edit: 'nsm/steps/work_items')
    from(:work_items)
      .when(-> { add_another.yes? })
      .goto(edit: 'nsm/steps/work_item', work_item_id: Nsm::StartPage::NEW_RECORD)
      .when(-> { any_invalid?(application.work_items, Nsm::Steps::WorkItemForm) })
      .goto(edit: 'nsm/steps/work_items')
      .goto(edit: 'nsm/steps/letters_calls')
    from(:letters_calls)
      .when(-> { application.disbursements.none? })
      .goto(edit: 'nsm/steps/disbursement_add')
      .goto(edit: 'nsm/steps/disbursements')
    from(:disbursement_add)
      .when(-> { has_disbursements.yes? })
      .goto(edit: 'nsm/steps/disbursement_type', disbursement_id: Nsm::StartPage::NEW_RECORD)
      .goto(show: 'nsm/steps/cost_summary')
    from(:disbursement_type)
      .goto(edit: 'nsm/steps/disbursement_cost', disbursement_id: -> { record.id })
    from(:disbursement_cost).goto(edit: 'nsm/steps/disbursements')
    from(:disbursement_delete)
      .when(-> { application.disbursements.none? })
      .goto(edit: 'nsm/steps/disbursement_type', disbursement_id: Nsm::StartPage::NEW_RECORD)
      .goto(edit: 'nsm/steps/disbursements')
    from(:disbursements)
      .when(-> { add_another.yes? })
      .goto(edit: 'nsm/steps/disbursement_type', disbursement_id: Nsm::StartPage::NEW_RECORD)
      .when(lambda {
              any_invalid?(application.disbursements, Nsm::Steps::DisbursementTypeForm,
                           Nsm::Steps::DisbursementCostForm)
            })
      .goto(edit: 'nsm/steps/disbursements')
      .goto(show: 'nsm/steps/cost_summary')
    # cost_summary to other_info is a hard coded link as show page
    from(:other_info).goto(edit: 'nsm/steps/supporting_evidence')
    from(:supporting_evidence).goto(show: 'nsm/steps/check_answers')
    # check_answers to equality is a hard coded link as show page
    from(:equality)
      .when(-> { answer_equality.yes? }).goto(edit: 'nsm/steps/equality_questions')
      .goto(edit: 'nsm/steps/solicitor_declaration')
    from(:equality_questions).goto(edit: 'nsm/steps/solicitor_declaration')
    from(:solicitor_declaration).goto(show: 'nsm/steps/claim_confirmation')

    # prior authority pre-draft application steps
    from(:prison_law).goto(edit: 'prior_authority/steps/authority_value')
    from(:authority_value).goto(edit: 'prior_authority/steps/ufn')
    from(:ufn).goto(show: 'prior_authority/steps/start_page')

    # prior authority draft application steps
    from(:case_contact).goto(edit: 'prior_authority/steps/client_detail')
    from(:client_detail).goto(show: 'prior_authority/steps/start_page') # TODO: move to case and hearing details
  end
end
