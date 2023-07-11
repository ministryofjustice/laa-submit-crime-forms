module CheckAnswers
  class YourDetailsCard < Base
    def initialize(claim)
      
    end

    def title
      I18n.t('steps.check_answers.groups.about_you.your_details.title')
    end
  end
end