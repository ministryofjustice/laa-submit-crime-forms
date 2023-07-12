module CheckAnswers
  class HearingDetailsCard
    def initialize(claim)
    
    end

    def route_path
      "hearing_details"
    end
    
    def title
      I18n.t('steps.check_answers.groups.about_case.hearing_details.title')
    end
  end
end
