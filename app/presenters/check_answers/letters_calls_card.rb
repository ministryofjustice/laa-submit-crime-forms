module CheckAnswers
  class LettersCallsCard < Base
    def initialize(claim)
    
    end
    
    def title
      I18n.t('steps.check_answers.groups.about_claim.letters_calls.title')
    end
  end
end
