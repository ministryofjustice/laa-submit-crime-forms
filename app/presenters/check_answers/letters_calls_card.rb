# frozen_string_literal: true

module CheckAnswers
  class LettersCallsCard < Base
    attr_reader :letters_calls_form

    def initialize(claim)
      @letters_calls_form = Steps::LettersCallsForm.build(claim)
      @group = 'about_claim'
      @section = 'letters_calls'
    end

    def route_path
      'letters_calls'
    end
  end
end
