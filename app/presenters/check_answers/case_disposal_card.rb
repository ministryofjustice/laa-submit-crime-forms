module CheckAnswers
  class CaseDisposalCard
    attr_reader :case_disposal_form

    def initialize(claim)
      @case_disposal_form = Steps::CaseDisposalForm.build(claim)
    end

    def route_path
      'case_disposal'
    end

    def title
      I18n.t('steps.check_answers.groups.about_case.case_disposal.title')
    end
  end
end
