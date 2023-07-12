module CheckAnswers
  class LettersCallsCard < Base
    attr_reader :letters_calls_form

    def initialize(claim)
      @letters_calls_form = Steps::LettersCallsForm.build(claim)
    end

    def route_path
      'letters_calls'
    end

    def title
      I18n.t('steps.check_answers.groups.about_claim.letters_calls.title')
    end
  end
end
