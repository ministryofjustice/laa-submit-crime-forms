module CheckAnswers
  class CaseDetailsCard
    attr_reader :case_details_form

    def initialize(claim)
      @case_details_form = Steps::CaseDetailsForm.build(claim)
    end

    def route_path
      'case_details'
    end

    def title
      I18n.t('steps.check_answers.groups.about_case.case_details.title')
    end
  end
end
