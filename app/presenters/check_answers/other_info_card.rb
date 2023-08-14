# frozen_string_literal: true

module CheckAnswers
  class OtherInfoCard < Base
    attr_reader :claim

    def initialize(claim)
      @claim = claim
      @group = 'about_claim'
      @section = 'other_info'
    end

    def row_data
      [
        {
          head_key: 'is_other_info',
          text: check_missing(claim.is_other_info.present?) do
            claim.is_other_info.capitalize
          end
        },
        other_info_row,
        {
          head_key: 'concluded',
          text: check_missing(claim.concluded.present?) do
            claim.concluded.capitalize
          end
        },
        conclusion_row
      ].compact
    end

    private
    
    def other_info_row
      return nil unless claim.is_other_info == YesNoAnswer::YES.to_s

      {
        head_key: 'other_info',
        text: check_missing(claim.other_info.present?) do 
          ApplicationController.helpers.multiline_text(claim.other_info)
        end
      }  
    end

    def conclusion_row
      return nil unless claim.concluded == YesNoAnswer::YES.to_s
 
      {
        head_key: 'conclusion',
        text: check_missing(claim.conclusion.present?) do
          ApplicationController.helpers.multiline_text(claim.conclusion)
        end
      }
    end
  end
end
