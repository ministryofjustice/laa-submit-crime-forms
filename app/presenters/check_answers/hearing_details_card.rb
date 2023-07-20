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
      {
        hearing_date: {
          head_key: 'hearing_date',
          text: hearing_details_form.first_hearing_date&.strftime('%d %B %Y')
        },
        number_of_hearing: {
          head_key: 'number_of_hearing',
          text: hearing_details_form.number_of_hearing
        },
        youth_count:  {
          head_key: 'youth_count',
          text: capitalize_sym(hearing_details_form.youth_count)
        },
        in_area: {
          head_key: 'in_area',
          text: in_area_text
        },
        hearing_outcome: {
          head_key: 'hearing_outcome',
          text: get_value_obj_desc(OutcomeCode, hearing_details_form.hearing_outcome)
        },
        matter_type: {
          head_key: 'matter_type',
          text: get_value_obj_desc(MatterType, hearing_details_form.matter_type)
        }
      }
    end
    # rubocop:enable Metrics/MethodLength

    private

    def in_area_text
      "#{capitalize_sym(hearing_details_form.in_area)} - #{hearing_details_form.court}"
    end
  end
end
