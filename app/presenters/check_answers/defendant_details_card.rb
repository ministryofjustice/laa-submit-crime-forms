module CheckAnswers
  class DefendantDetailsCard < Base
    def initialize(claim)
    
    end

    def route_path
      "defendant_summary"
    end
    
    def title
      I18n.t('steps.check_answers.groups.about_defendant.defendant_details.title')
    end
  end
end
