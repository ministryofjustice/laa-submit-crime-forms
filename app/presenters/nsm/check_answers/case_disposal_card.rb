# frozen_string_literal: true

module Nsm
  module CheckAnswers
    class CaseDisposalCard < Base
      attr_reader :case_disposal_form

      def initialize(claim)
        @case_disposal_form = Nsm::Steps::CaseDisposalForm.build(claim)
        @group = 'about_case'
        @section = 'case_disposal'
      end

      def find_key_by_value(value_to_find)
        return :pending if value_to_find.blank?

        PleaOptions.new(value_to_find).category
      end

      def row_data
        row_data_array = [
          {
            head_key: find_key_by_value(case_disposal_form.plea),
            text: check_missing(case_disposal_form.plea) do
                    I18n.t("helpers.label.nsm_steps_case_disposal_form.plea_options.#{case_disposal_form.plea}")
                  end
          }
        ]
        add_date_object(row_data_array, 'cracked_trial_date', case_disposal_form.cracked_trial_date)
        add_date_object(row_data_array, 'arrest_warrant_date', case_disposal_form.arrest_warrant_date)
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
end
