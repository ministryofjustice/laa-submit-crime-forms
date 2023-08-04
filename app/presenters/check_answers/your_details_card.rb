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
      data = [
        {
          head_key: 'firm_name',
          text: check_missing(firm_details_form.firm_office.name)
        },
        {
          head_key: 'firm_account_number',
          text: check_missing(firm_details_form.firm_office.account_number)
        },
        {
          head_key: 'firm_address',
          text: check_missing(firm_details_form.firm_office) { format_address(firm_details_form.firm_office) }
        },
        {
          head_key: 'solicitor_full_name',
          text: check_missing(firm_details_form.solicitor.full_name)
        },
        {
          head_key: 'solicitor_reference_number',
          text: check_missing(firm_details_form.solicitor.reference_number)
        },
      ]

      if firm_details_form.solicitor.contact_full_name || firm_details_form.solicitor.contact_email
        data += [
          {
            head_key: 'contact_full_name',
            text: check_missing(firm_details_form.solicitor.contact_full_name)
          },
          {
            head_key: 'contact_email',
            text: check_missing(firm_details_form.solicitor.contact_email)
          }
        ]
      end

      data
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    private

    def format_address(firm_office)
      address = []
      valid = add_field(address, firm_office.address_line_1, true)
      address << firm_office.address_line_2
      valid = add_field(address, firm_office.town, valid)
      add_field(address, firm_office.postcode, valid)

      formatted_string = address.compact.join('<br>')

      ApplicationController.helpers.sanitize(formatted_string, tags: %w[br strong])
    end

    # we only want to add the missing data tag
    # once for the first missing field
    # this ensure that it can only be invalid once, and the
    # block return value is ignored unless it is valid
    def add_field(address, field, valid)
      address << check_missing(!valid || field) do
        valid ? field : nil
      end
      valid && field.present?
    end
  end
end
