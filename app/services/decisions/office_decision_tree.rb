module Decisions
  class OfficeDecisionTree < DslDecisionTree
    from(:select_office)
      .goto(index: '/nsm/claims')
    from(:confirm_office)
      .when(-> { is_current_office.yes? })
      .goto(index: '/nsm/claims')
      .goto(edit: '/nsm/steps/office/select')
  end
end
