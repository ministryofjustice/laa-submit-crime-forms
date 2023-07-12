module CheckAnswers
  class HearingDetailsCard < Base
    attr_reader :hearing_details_form

    def initialize(claim)
      @hearing_details_form = Steps::HearingDetailsForm.build(claim)
    end

    def route_path
      'hearing_details'
    end

    def title
      I18n.t('steps.check_answers.groups.about_case.hearing_details.title')
    end
  end
end
