# frozen_string_literal: true

module CheckAnswers
  class DefendantDetailsCard < Base
    attr_reader :defendant_details

    KEY = 'defendant_summary'
    GROUP = 'about_defendant'
    def initialize(claim)
      @defendant_details = claim.defendants
      @group = GROUP
      @section = KEY
    end

    def route_path
      KEY
    end

    def rows
      all_rows = main_defendant_rows
      additional_defendants.each_with_index do |defendant, index|
        all_rows.concat additional_defendant_rows(defendant, index + 1)
      end
      all_rows
    end

    private

    def main_defendant
      defendant_details.find { |defendant| defendant[:main] == true }
    end

    def additional_defendants
      defendant_details.select { |defendant| defendant[:main] == false }
    end

    def main_defendant_rows
      [
        {
          key: { text: translate_table_key(KEY, 'main_defendant_full_name'),
classes: 'govuk-summary-list__value-width-50' },
          value: { text: main_defendant[:full_name] }
        },
        {
          key: { text: translate_table_key(KEY, 'main_defendant_maat'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: main_defendant[:maat] }
        }
      ]
    end

    def additional_defendant_rows(defendant, index)
      [
        {
          key: { text: translate_table_key(KEY, 'additional_defendant_full_name', count: index),
classes: 'govuk-summary-list__value-width-50' },
          value: { text: defendant[:full_name] }
        },
        {
          key: { text: translate_table_key(KEY, 'additional_defendant_maat', count: index),
classes: 'govuk-summary-list__value-width-50' },
          value: { text: defendant[:maat] }
        }
      ]
    end
  end
end
