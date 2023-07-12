module CheckAnswers
  class OtherInfoCard < Base
    def initialize(claim)
    
    end

    def route_path
      "other_info"
    end
    
    def title
      I18n.t('steps.check_answers.groups.about_claim.other_info.title')
    end
  end
end
