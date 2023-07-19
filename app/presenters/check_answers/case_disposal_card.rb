# frozen_string_literal: true

module CheckAnswers
  class CaseDisposalCard < Base
    attr_reader :case_disposal_form

    KEY = 'case_disposal'
    GROUP = 'about_case'

    def initialize(claim)
      @case_disposal_form = Steps::CaseDisposalForm.build(claim)
      @group = GROUP
      @section = KEY
    end

    def route_path
      'case_disposal'
    end
  end
end
