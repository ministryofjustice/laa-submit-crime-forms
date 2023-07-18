module CheckAnswers
  class CaseDisposalCard < Base
    attr_reader :case_disposal_form

    KEY = 'case_disposal'.freeze
    GROUP = 'about_case'.freeze

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
