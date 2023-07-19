# frozen_string_literal: true

module CheckAnswers
  class DefendantDetailsCard < Base
    attr_reader :defendant_details

    def initialize(claim)
      @defendant_details = claim.defendants
      @group = 'about_defendant'
      @section = 'defendant_summary'
    end

    # def rows
    #   all_rows = main_defendant_rows
    #   additional_defendants.each_with_index do |defendant, index|
    #     all_rows.concat additional_defendant_rows(defendant, index + 1)
    #   end
    #   all_rows
    # end

    private

    def main_defendant
      defendant_details.find { |defendant| defendant[:main] == true }
    end

    def additional_defendants
      defendant_details.select { |defendant| defendant[:main] == false }
    end

    def main_defendant_rows
      {

      }
    end

    def additional_defendant_rows(defendant, index)
      {
        additional_defendant_full_name: { text: defendant[:full_name] },
        additional_defendant_maat: { 
          text: defendant[:maat],
          head_opts: { count: index } 
        }
      }
    end
  end
end
