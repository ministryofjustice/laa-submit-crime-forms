# frozen_string_literal: true

module CheckAnswers
  class YourDetailsCard < Base
    attr_reader :firm_details_form

    def initialize(claim)
      @firm_details_form = Steps::FirmDetailsForm.build(claim)
      @group = 'about_you'
      @section = 'firm_details'
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def row_data
      [
        {
          head_key: 'firm_name',
          text: firm_details_form.firm_office.name
        },
        {
          head_key: 'firm_account_number',
          text: firm_details_form.firm_office.account_number
        },
        {
          head_key: 'firm_address',
          text: format_address(firm_details_form.firm_office.address_line_1,
                               firm_details_form.firm_office.town,
                               firm_details_form.firm_office.postcode,
                               firm_details_form.firm_office.address_line_2)
        },
        {
          head_key: 'solicitor_full_name',
          text: firm_details_form.solicitor.full_name
        },
        {
          head_key: 'solicitor_reference_number',
          text: firm_details_form.solicitor.reference_number
        },
        {
          head_key: 'contact_full_name',
          text: firm_details_form.solicitor.contact_full_name
        }
      ]
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    private

    def format_address(address_line_1, town, postcode, address_line_2 = nil)
      formatted_string = "#{address_line_1}<br>" \
                         "#{address_line_2.present? ? "#{address_line_2}<br>" : nil}" \
                         "#{town}<br>#{postcode}"
      ApplicationController.helpers.sanitize(formatted_string, tags: %w[br])
    end
  end
end
