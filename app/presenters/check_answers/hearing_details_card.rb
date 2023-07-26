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
          text: hearing_details_form.first_hearing_date&.strftime('%d %B %Y')
        },
        {
          head_key: 'number_of_hearing',
          text: hearing_details_form.number_of_hearing
        },
        {
          head_key: 'youth_count',
          text: ApplicationController.helpers.capitalize_sym(hearing_details_form.youth_count)
        },
        {
          head_key: 'in_area',
          text: in_area_text
        },
        {
          head_key: 'hearing_outcome',
          text: get_value_obj_desc(OutcomeCode, hearing_details_form.hearing_outcome)
        },
        {
          head_key: 'matter_type',
          text: get_value_obj_desc(MatterType, hearing_details_form.matter_type)
        }
      ]
    end
    # rubocop:enable Metrics/MethodLength

    private

    def in_area_text
      "#{ApplicationController.helpers.capitalize_sym(hearing_details_form.in_area)} - #{hearing_details_form.court}"
    end
  end
end
