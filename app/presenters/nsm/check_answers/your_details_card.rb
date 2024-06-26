# frozen_string_literal: true

module Nsm
  module CheckAnswers
    class YourDetailsCard < Base
      attr_reader :firm_details_form

      def initialize(claim)
        @firm_details_form = Nsm::Steps::FirmDetailsForm.build(claim)
        @group = 'about_you'
        @section = 'firm_details'
      end

      # rubocop:disable Metrics/AbcSize
      def row_data
        data = [
          {
            head_key: 'firm_name',
            text: check_missing(firm_details_form.firm_office.name)
          },
          {
            head_key: 'firm_account_number',
            text: check_missing(firm_details_form.application.office_code)
          },
          {
            head_key: 'firm_address',
            text: format_address(firm_details_form.firm_office)
          },
          {
            head_key: 'vat_registered',
            text: check_missing(firm_details_form.firm_office.vat_registered.to_s.capitalize)
          },
          {
            head_key: 'solicitor_first_name',
            text: check_missing(firm_details_form.solicitor.first_name)
          },
          {
            head_key: 'solicitor_last_name',
            text: check_missing(firm_details_form.solicitor.last_name)
          },
          {
            head_key: 'solicitor_reference_number',
            text: check_missing(firm_details_form.solicitor.reference_number)
          },
        ]

        if firm_details_form.solicitor.contact_first_name ||
           firm_details_form.solicitor.contact_last_name ||
           firm_details_form.solicitor.contact_email
          data += [
            {
              head_key: 'contact_first_name',
              text: check_missing(firm_details_form.solicitor.contact_first_name)
            },
            {
              head_key: 'contact_last_name',
              text: check_missing(firm_details_form.solicitor.contact_last_name)
            },
            {
              head_key: 'contact_email',
              text: check_missing(firm_details_form.solicitor.contact_email)
            }
          ]
        end

        data
      end
      # rubocop:enable Metrics/AbcSize

      private

      def format_address(firm_office)
        address = []
        valid = add_field(address, firm_office.address_line_1, true)
        address << firm_office.address_line_2.presence
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
          field.presence
        end
        valid && field.present?
      end
    end
  end
end
