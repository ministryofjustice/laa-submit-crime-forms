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
          text: ActionController::Base.helpers.sanitize(formatted_info, tags: %w[br])
        }
      ]
    end

    private 

    def formatted_info
      other_info_form.other_info.gsub(/\n/, '<br>')
    end
  end
end
