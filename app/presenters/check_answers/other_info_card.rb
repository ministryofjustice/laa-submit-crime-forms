# frozen_string_literal: true

module CheckAnswers
  class OtherInfoCard < Base
    attr_reader :other_info_form

    def initialize(claim)
      @other_info_form = Steps::OtherInfoForm.build(claim)
      @group = 'about_claim'
      @section = 'other_info'
    end

    def route_path
      'other_info'
    end
  end
end
