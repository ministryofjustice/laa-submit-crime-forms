# frozen_string_literal: true
module CheckAnswers
  class LettersCallsCard < Base
    attr_reader :letters_calls_form

    KEY = 'letters_calls'
    GROUP = 'about_claim'

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
