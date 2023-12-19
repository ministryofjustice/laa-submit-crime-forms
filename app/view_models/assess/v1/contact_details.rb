module Assess
  module V1
    class ContactDetails < Assess::BaseViewModel
      attribute :firm_office
      attribute :solicitor
      attribute :submitter

      def key
        'contact_details'
      end

      def title
        I18n.t("assess.claim_details.#{key}.title")
      end

      def firm_name
        firm_office&.[]('name')
      end

      def firm_account_number
        firm_office&.[]('account_number')
      end

      def solicitor_full_name
        solicitor&.[]('full_name')
      end

      def solicitor_ref_number
        solicitor&.[]('reference_number')
      end

      def contact_full_name
        solicitor&.[]('contact_full_name')
      end

      def contact_email
        solicitor&.[]('contact_email')
      end

      def firm_address
        ApplicationController.helpers.sanitize([
          firm_office&.[]('address_line_1'),
          firm_office&.[]('address_line_2'),
          firm_office&.[]('town'),
          firm_office&.[]('postcode')
        ].compact.join('<br>'),
                                               tags: %w[br])
      end

      def provider_email_address
        submitter&.[]('email')
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def data
        [
          {
            title: I18n.t("assess.claim_details.#{key}.firm_name"),
            value: firm_name
          },
          {
            title: I18n.t("assess.claim_details.#{key}.firm_account_number"),
            value: firm_account_number
          },
          {
            title: I18n.t("assess.claim_details.#{key}.firm_address"),
            value: firm_address
          },
          {
            title: I18n.t("assess.claim_details.#{key}.solicitor_full_name"),
            value: solicitor_full_name
          },
          {
            title: I18n.t("assess.claim_details.#{key}.solicitor_ref_number"),
            value: solicitor_ref_number
          },
          *contact_details,
          {
            title: I18n.t("assess.claim_details.#{key}.provider_email"),
            value: provider_email_address
          }
        ]
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def rows
        { title:, data: }
      end

      def contact_details
        return [] if contact_email.blank?

        [
          {
            title: I18n.t("assess.claim_details.#{key}.contact_full_name"),
            value: contact_full_name
          },
          {
            title: I18n.t("assess.claim_details.#{key}.contact_email"),
            value: contact_email
          },

        ]
      end
    end
  end
end
