module CheckAnswers
  class LettersCallsCard < Base
    attr_reader :letters_calls_form

    KEY = 'letters_calls'.freeze
    GROUP = 'about_claim'.freeze

    def initialize(claim)
      @letters_calls_form = Steps::LettersCallsForm.build(claim)
      @group = GROUP
      @section = KEY
    end

    def route_path
      'letters_calls'
    end
  end
end
