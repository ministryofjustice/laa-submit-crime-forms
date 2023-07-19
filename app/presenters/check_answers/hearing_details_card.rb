# frozen_string_literal: true

module CheckAnswers
  class HearingDetailsCard < Base
    attr_reader :hearing_details_form

    def initialize(claim)
      @hearing_details_form = Steps::HearingDetailsForm.build(claim)
      @group = 'about_case'
      @section = 'hearing_details'
    end

    # TODO: Add row for proceedings concluded...
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def rows
      [
        {
          key: { text: translate_table_key(section, 'hearing_date'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: hearing_details_form.first_hearing_date&.strftime('%d %B %Y') }
        },
        {
          key: { text: translate_table_key(section, 'number_of_hearing'),
classes: 'govuk-summary-list__value-width-50' },
          value: { text: hearing_details_form.number_of_hearing }
        },
        {
          key: { text: translate_table_key(section, 'youth_count'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: capitalize_sym(hearing_details_form.youth_count) }
        },
        {
          key: { text: translate_table_key(section, 'in_area'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: in_area_text }
        },
        {
          key: { text: translate_table_key(section, 'hearing_outcome'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: get_value_obj_desc(OutcomeCode, hearing_details_form.hearing_outcome) }
        },
        {
          key: { text: translate_table_key(section, 'matter_type'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: get_value_obj_desc(MatterType, hearing_details_form.matter_type) }
        }
      ]
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    private

    def in_area_text
      "#{capitalize_sym(hearing_details_form.in_area)} - #{hearing_details_form.court}"
    end
  end
end
