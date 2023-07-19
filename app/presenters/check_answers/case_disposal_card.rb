# frozen_string_literal: true

module CheckAnswers
  class CaseDisposalCard < Base
    attr_reader :case_disposal_form

    def initialize(claim)
      @case_disposal_form = Steps::CaseDisposalForm.build(claim)
      @group = 'about_case'
      @section = 'case_disposal'
    end

    def route_path
      'case_disposal'
    end
  end
end
