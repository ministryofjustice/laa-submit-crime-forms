module Decisions
  class DecisionTree < DslDecisionTree
    # used to add custom methods to filter/query the data
    WRAPPER_CLASS = CustomWrapper

    NSM_FIRM_DETAILS = 'nsm/steps/firm_details'.freeze
    NSM_WORK_ITEMS = 'nsm/steps/work_items'.freeze
    NSM_WORK_ITEM = 'nsm/steps/work_item'.freeze
    NSM_DEFENDANT_SUMMARY = 'nsm/steps/defendant_summary'.freeze
    NSM_DISBURSEMENTS = 'nsm/steps/disbursements'.freeze
    NSM_DISBURSEMENT_TYPE = 'nsm/steps/disbursement_type'.freeze
    NSM_CLAIM_DETAILS = 'nsm/steps/claim_details'.freeze
    NSM_LETTERS_CALLS = 'nsm/steps/letters_calls'.freeze
    NSM_DISBURSEMENT_ADD = 'nsm/steps/disbursement_add'.freeze
    NSM_EQUALITY = 'nsm/steps/equality'.freeze

    from(:claim_type).goto(show: 'nsm/steps/start_page')
    # start_page to firm_details is a hard coded link as show page
    from(:firm_details)
      .when(-> { application.submitter.office_codes.count > 1 })
      .goto(edit: 'nsm/steps/office_code')
      .when(-> { application.defendants.none? })
      .goto(edit: 'nsm/steps/defendant_details', defendant_id: Nsm::StartPage::NEW_RECORD)
      .goto(edit: NSM_DEFENDANT_SUMMARY)
    from(:office_code)
      .when(-> { application.defendants.none? })
      .goto(edit: 'nsm/steps/defendant_details', defendant_id: Nsm::StartPage::NEW_RECORD)
      .goto(edit: NSM_DEFENDANT_SUMMARY)
    from(:defendant_details).goto(edit: NSM_DEFENDANT_SUMMARY)
    from(:defendant_delete).goto(edit: NSM_DEFENDANT_SUMMARY)
    from(:defendant_summary)
      .when(-> { add_another.yes? })
      .goto(edit: 'nsm/steps/defendant_details', defendant_id: Nsm::StartPage::NEW_RECORD)
      .when(-> { any_invalid?(application.defendants, Nsm::Steps::DefendantDetailsForm) })
      .goto(edit: NSM_DEFENDANT_SUMMARY)
      .goto(edit: 'nsm/steps/case_details')
    from(:case_details).goto(edit: 'nsm/steps/hearing_details')
    from(:hearing_details).goto(edit: 'nsm/steps/case_disposal')
    from(:case_disposal).goto(edit: 'nsm/steps/reason_for_claim')
    from(:reason_for_claim).goto(edit: NSM_CLAIM_DETAILS)
    from(:claim_details)
      .when(-> { application.work_items.none? })
      .goto(edit: NSM_WORK_ITEM, work_item_id: Nsm::StartPage::NEW_RECORD)
      .goto(edit: NSM_WORK_ITEMS)
    from(:work_item).goto(edit: NSM_WORK_ITEMS)
    from(:work_item_delete)
      .when(-> { application.work_items.none? })
      .goto(edit: NSM_WORK_ITEM, work_item_id: Nsm::StartPage::NEW_RECORD)
      .goto(edit: NSM_WORK_ITEMS)
    from(:work_items)
      .when(-> { add_another.yes? })
      .goto(edit: NSM_WORK_ITEM, work_item_id: Nsm::StartPage::NEW_RECORD)
      .when(-> { any_invalid?(application.work_items, Nsm::Steps::WorkItemForm) })
      .goto(edit: NSM_WORK_ITEMS)
      .goto(edit: NSM_LETTERS_CALLS)
    from(:letters_calls)
      .when(-> { application.disbursements.none? })
      .goto(edit: NSM_DISBURSEMENT_ADD)
      .goto(edit: NSM_DISBURSEMENTS)
    from(:disbursement_add)
      .when(-> { has_disbursements.yes? })
      .goto(edit: NSM_DISBURSEMENT_TYPE, disbursement_id: Nsm::StartPage::NEW_RECORD)
      .goto(show: 'nsm/steps/cost_summary')
    from(:disbursement_type)
      .goto(edit: 'nsm/steps/disbursement_cost', disbursement_id: -> { record.id })
    from(:disbursement_cost).goto(edit: NSM_DISBURSEMENTS)
    from(:disbursement_delete)
      .when(-> { application.disbursements.none? })
      .goto(edit: NSM_DISBURSEMENT_TYPE, disbursement_id: Nsm::StartPage::NEW_RECORD)
      .goto(edit: NSM_DISBURSEMENTS)
    from(:disbursements)
      .when(-> { add_another.yes? })
      .goto(edit: NSM_DISBURSEMENT_TYPE, disbursement_id: Nsm::StartPage::NEW_RECORD)
      .when(lambda {
              any_invalid?(application.disbursements, Nsm::Steps::DisbursementTypeForm,
                           Nsm::Steps::DisbursementCostForm)
            })
      .goto(edit: NSM_DISBURSEMENTS)
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

    PRIOR_AUTHORITY_START_PAGE = 'prior_authority/steps/start_page'.freeze
    PRIOR_AUTHORITY_CHECK_ANSWERS = 'prior_authority/steps/check_answers'.freeze
    PRIOR_AUTHORITY_PRIMARY_QUOTE_SUMMARY = 'prior_authority/steps/primary_quote_summary'.freeze
    PRIOR_AUTHORITY_ADDITIONAL_COSTS = 'prior_authority/steps/additional_costs'.freeze
    PRIOR_AUTHORITY_ALTERNATIVE_QUOTES = 'prior_authority/steps/alternative_quotes'.freeze

    # pre-draft application steps
    from(:prison_law).goto(edit: 'prior_authority/steps/authority_value')
    from(:authority_value).goto(edit: 'prior_authority/steps/ufn')
    from(:ufn)
      .when(-> { application.navigation_stack[-1].match?('check_answers') })
      .goto(edit: PRIOR_AUTHORITY_CHECK_ANSWERS)
      .goto { overwrite_to_cya  }

    # ---------------------------------
    # prior authority application steps
    # ---------------------------------

    from(:case_contact)
      .goto { overwrite_to_cya  }

    from(:client_detail)
      .goto { overwrite_to_cya  }

    # prison law flow
    from(:next_hearing)
      .goto { overwrite_to_cya  }

    # non-prison law flow
    from(:case_detail)
      .goto { overwrite_to_cya(destination: 'prior_authority/steps/hearing_detail', action: :edit) }

    from(:hearing_detail)
      .when(-> { application.court_type == PriorAuthority::CourtTypeOptions::MAGISTRATE.to_s })
      .goto(edit: 'prior_authority/steps/youth_court')
      .when(-> { application.court_type == PriorAuthority::CourtTypeOptions::CENTRAL_CRIMINAL.to_s })
      .goto(edit: 'prior_authority/steps/psychiatric_liaison')
      .goto { overwrite_to_cya  }

    from(:youth_court)
      .goto { overwrite_to_cya  }

    from(:psychiatric_liaison)
      .goto { overwrite_to_cya  }

    # primary quote
    from(:primary_quote).goto(edit: 'prior_authority/steps/service_cost')
    from(:service_cost).goto(show: PRIOR_AUTHORITY_PRIMARY_QUOTE_SUMMARY)

    from(:travel_detail).goto(show: PRIOR_AUTHORITY_PRIMARY_QUOTE_SUMMARY)
    from(:delete_travel).goto(show: PRIOR_AUTHORITY_PRIMARY_QUOTE_SUMMARY)
    from(:primary_quote_summary)
      .goto { overwrite_to_cya  }
    from(:additional_costs)
      .when(-> { application.additional_costs_still_to_add })
      .goto(new: 'prior_authority/steps/additional_cost_details')
      .goto(show: PRIOR_AUTHORITY_PRIMARY_QUOTE_SUMMARY)

    from(:additional_cost_details)
      .goto(edit: PRIOR_AUTHORITY_ADDITIONAL_COSTS)

    # alternative quotes
    from(:alternative_quotes)
      .when(-> { application.alternative_quotes_still_to_add })
      .goto(new: 'prior_authority/steps/alternative_quote_details')
      .goto { overwrite_to_cya }

    from(:alternative_quote_details)
      .goto(edit: PRIOR_AUTHORITY_ALTERNATIVE_QUOTES)

    from(:reason_why)
      .goto { overwrite_to_cya }

    from(:further_information)
      .goto { overwrite_to_cya }

    from(:check_answers)
      .goto(show: 'prior_authority/steps/submission_confirmation')
  end
end
