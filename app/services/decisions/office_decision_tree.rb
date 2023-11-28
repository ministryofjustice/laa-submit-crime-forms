module Decisions
  class OfficeDecisionTree < DslDecisionTree
    from(:select_office)
      .goto(index: '/claims')
    from(:confirm_office)
      .when(-> { is_current_office.yes? })
      .goto(index: '/claims')
      .goto(edit: 'steps/office/select')
  end
end
