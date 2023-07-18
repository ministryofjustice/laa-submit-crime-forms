module CheckAnswers
  class OtherInfoCard < Base
    attr_reader :other_info_form

    KEY = 'other_info'.freeze
    GROUP = 'about_claim'.freeze

    def initialize(claim)
      @other_info_form = Steps::OtherInfoForm.build(claim)
      @group = GROUP
      @section = KEY
    end

    def route_path
      'other_info'
    end
  end
end
