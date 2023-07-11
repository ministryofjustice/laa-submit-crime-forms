module CheckAnswers
  class HearingDetailsCard < Base
    def initialize(claim)
    
    end
    
    def title
      I18n.t('steps.check_answers.groups.about_case.hearing_details.title')
    end
  end
end
