# frozen_string_literal: true

module CheckAnswers
  class YourDetailsCard < Base
    attr_reader :firm_details_form

    KEY = 'firm_details'
    GROUP = 'about_you'

    def initialize(claim)
      @firm_details_form = Steps::FirmDetailsForm.build(claim)
      @group = GROUP
      @section = KEY
    end

    def route_path
      KEY
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def rows
      [
        {
          key: { text: translate_table_key(KEY, 'firm_name'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: firm_details_form.firm_office.name }
        },
        {
          key: { text: translate_table_key(KEY, 'firm_account_number'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: firm_details_form.firm_office.account_number }
        },
        {
          key: { text: translate_table_key(KEY, 'firm_address'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: format_address(firm_details_form.firm_office.address_line_1,
                                        firm_details_form.firm_office.town,
                                        firm_details_form.firm_office.postcode,
                                        firm_details_form.firm_office.address_line_2) }
        },
        {
          key: { text: translate_table_key(KEY, 'solicitor_full_name'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: firm_details_form.solicitor.full_name }
        },
        {
          key: { text: translate_table_key(KEY, 'solicitor_reference_number'),
classes: 'govuk-summary-list__value-width-50' },
          value: { text: firm_details_form.solicitor.reference_number }
        },
        {
          key: { text: translate_table_key(KEY, 'contact_full_name'),
classes: 'govuk-summary-list__value-width-50' },
          value: { text: firm_details_form.solicitor.contact_full_name }
        }
      ]
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    private

    def format_address(address_line_1, town, postcode, address_line_2 = nil)
      formatted_string = "#{address_line_1}<br>" \
                         "#{address_line_2.present? ? "#{address_line_2}<br>" : nil}" \
                         "#{town}<br>#{postcode}"
      ActionController::Base.helpers.sanitize(formatted_string, tags: %w[br])
    end
  end
end
