# frozen_string_literal: true

module CheckAnswers
  class CaseDisposalCard < Base
    attr_reader :case_disposal_form

    def initialize(claim)
      @case_disposal_form = Steps::CaseDisposalForm.build(claim)
      @group = 'about_case'
      @section = 'case_disposal'
    end

    def find_key_by_value(value_to_find)
      choices = {
        guilty_pleas: PleaOptions::GUILTY_OPTIONS,
        not_guilty_pleas: PleaOptions::NOT_GUILTY_OPTIONS,
      }
      choices.each do |key, options|
        return key if options.include?(value_to_find)
      end
      nil # Return nil if the value is not found in any of the choices
    end

    def transform_value(value)
      # Convert the value to a string representation
      value_string = value.to_s
      # Apply the transformation i.e convert 'bind_over' to 'Bind over'
      value_string.split('_').map.with_index do |word, index|
        index.zero? ? word.capitalize : word.downcase
      end.join(' ')
    end

    def row_data
      row_data_array = [
        {
          head_key: find_key_by_value(case_disposal_form.plea),
          text: transform_value(case_disposal_form.plea)
        }
      ]
      add_date_object(row_data_array, 'cracked_trial_date', case_disposal_form.cracked_trial_date)
      add_date_object(row_data_array, 'arrest_warrent_date', case_disposal_form.arrest_warrent_date)
      row_data_array
    end

    private

    def add_date_object(array, head_key, date_value)
      return unless date_value

      array << {
        head_key: head_key,
        text: date_value.strftime('%d %B %Y')
      }
    end
  end
end
