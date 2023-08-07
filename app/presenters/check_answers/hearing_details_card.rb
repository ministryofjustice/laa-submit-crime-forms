# frozen_string_literal: true

module CheckAnswers
  class HearingDetailsCard < Base
    attr_reader :hearing_details_form

    def initialize(claim)
      @hearing_details_form = Steps::HearingDetailsForm.build(claim)
      @group = 'about_case'
      @section = 'hearing_details'
    end

    # rubocop:disable Metrics/MethodLength
    def row_data
      [
        {
          head_key: 'hearing_date',
          text: check_missing(hearing_details_form.first_hearing_date) do
            hearing_details_form.first_hearing_date.strftime('%d %B %Y')
          end
        },
        {
          head_key: 'number_of_hearing',
          text: check_missing(hearing_details_form.number_of_hearing)
        },
        {
          head_key: 'youth_count',
          text: check_missing(hearing_details_form.youth_count.present?) do
            capitalize_sym(hearing_details_form.youth_count)
          end
        },
        {
          head_key: 'in_area',
          text: check_missing(hearing_details_form.in_area.present? && hearing_details_form.court.present?) do
            "#{capitalize_sym(hearing_details_form.in_area)} - #{hearing_details_form.court}"
          end
        },
        {
          head_key: 'hearing_outcome',
          text: check_missing(hearing_details_form.hearing_outcome.present?) do
            get_value_obj_desc(OutcomeCode, hearing_details_form.hearing_outcome)
          end
        },
        {
          head_key: 'matter_type',
          text: check_missing(hearing_details_form.matter_type.present?) do
            get_value_obj_desc(MatterType, hearing_details_form.matter_type)
          end
        }
      ]
    end
    # rubocop:enable Metrics/MethodLength
  end
end
