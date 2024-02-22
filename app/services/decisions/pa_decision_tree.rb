module Decisions
  class PaDecisionTree < DslDecisionTree
    # used to add custom methods to filter/query the data
    WRAPPER_CLASS = CustomWrapper

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

    from(:check_answers)
      .goto(show: 'prior_authority/steps/submission_confirmation')
  end
end
