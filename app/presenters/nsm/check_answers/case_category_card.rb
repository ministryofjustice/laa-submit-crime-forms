# frozen_string_literal: true

module Nsm
  module CheckAnswers
    class CaseCategoryCard < Base
      attr_reader :case_category_form,
                  :case_outcome_form, :case_youth_court_fee

      def initialize(claim)
        @case_category_form = Nsm::Steps::CaseCategoryForm.build(claim)
        @case_outcome_form = Nsm::Steps::CaseOutcomeForm.build(claim)
        @case_youth_court_fee = Nsm::Steps::YouthCourtClaimAdditionalFeeForm.build(claim)

        @group = 'about_case'
        @section = 'case_category'
      end

      def row_data
        row_data_array = [
          {
            head_key: find_key_by_value(case_category_form.plea_category),
            text: format_plea_outcome
          }
        ]

        add_additional_fee(row_data_array, :additional_fee, case_youth_court_fee.include_youth_court_fee)
        add_date_object(row_data_array, :arrest_warrant_date, case_outcome_form.arrest_warrant_date)
        add_date_object(row_data_array, :change_solicitor_date, case_outcome_form.change_solicitor_date)

        row_data_array
      end

      private

      def add_additional_fee(row_data_array, head_key, value)
        return if value.nil?

        row_data_array << {
          head_key: head_key,
          text: I18n.t("nsm.steps.check_answers.show.sections.case_category.additional_fee_options.#{value}")
        }
      end

      def format_plea_outcome
        if case_outcome_form.other?
          other = I18n.t("laa_crime_forms_common.nsm.plea.#{case_outcome_form.plea}")
          "#{other}: #{case_outcome_form.case_outcome_other_info}"
        else
          check_missing(case_outcome_form.plea) do
            I18n.t("laa_crime_forms_common.nsm.plea.#{case_outcome_form.plea}")
          end
        end
      end

      def add_date_object(array, head_key, date_value)
        return unless date_value

        array << {
          head_key: head_key,
          text: date_value.to_fs(:stamp)
        }
      end

      def find_key_by_value(value_to_find)
        return :pending if value_to_find.blank?

        PleaCategory.new(value_to_find).value
      end
    end
  end
end
