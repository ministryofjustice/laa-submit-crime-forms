# frozen_string_literal: true

module CheckAnswers
  class OtherInfoCard < Base
    attr_reader :other_info_form

    def initialize(claim)
      @other_info_form = Steps::OtherInfoForm.build(claim)
      @group = 'about_claim'
      @section = 'other_info'
    end

    def row_data
      [
        {
          head_key: 'other_info',
          text: ApplicationController.helpers.multiline_text(other_info_form.other_info)
        }
      ]
    end
  end
end
