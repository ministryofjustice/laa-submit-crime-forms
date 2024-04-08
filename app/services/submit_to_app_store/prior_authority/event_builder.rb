class SubmitToAppStore
  module PriorAuthority
    class EventBuilder
      def self.call(application, new_data)
        new(application, new_data).payload
      end

      def initialize(application, new_data)
        @application = application
        @new_data = new_data.deep_stringify_keys
      end

      def payload
        return [] unless @application.provider_updated?

        [
          {
            id: SecureRandom.uuid,
            event_type: 'provider_updated',
            details: {
              comment: 'TODO: Extract from latest further_information',
              documents: [], # TODO: Extract from latest further_information
              corrected_info: corrected_info
            },
          }
        ]
      end

      def corrected_info
        @old_data = AppStoreClient.new.get(@application.id)['application']
        [
          change_key(:ufn),
          change_key(:case_contact),
          change_key(:client_detail),
          change_key(:case_detail),
          change_key(:hearing_detail),
          change_key(:next_hearing),
          change_key(:primary_quote),
          change_key(:reason_why),
          alternative_quote_change_keys,
        ].flatten.compact
      end

      def change_key(key)
        key if send(:"#{key}_changed?")
      end

      def ufn_changed?
        different?(:ufn)
      end

      def case_contact_changed?
        different?(:firm_office) || different?(:solicitor)
      end

      def client_detail_changed?
        [:first_name, :last_name, :date_of_birth].any? { different?([:defendant, _1]) }
      end

      def case_detail_changed?
        [:main_offence_id,
         :custom_main_offence_name,
         :prison_id,
         :custom_prison_name,
         :rep_order_date,
         :client_detained,
         :subject_to_poca,
         [:defendant, :maat]].any? { different?(_1) }
      end

      def hearing_detail_changed?
        [:next_hearing_date,
         :plea,
         :court_type,
         :youth_court,
         :psychiatric_liaison,
         :psychiatric_liaison_reason_not].any? { different?(_1) }
      end

      def next_hearing_changed?
        different?(:next_hearing) || different?(:next_hearing_data)
      end

      def primary_quote_changed?
        [:prior_authority_granted, :service_type, :custom_service_name, :additional_costs].any? { different?(_1) } ||
          @old_data['quotes'].find { _1['primary'] } != @new_data['quotes'].find { _1['primary'] }
      end

      def reason_why_changed?
        different?(:reason_why) || different?(:supporting_documents)
      end

      def alternative_quote_change_keys
        return 'alternative_quote_1' if different?(:no_alternative_quote_reason)

        @new_data['quotes'].reject { _1['primary'] }.each_with_index.map do |quote, index|
          "alternative_quote_#{index + 1}" if quote != @old_data['quotes'].find { _1['id'] == quote['id'] }
        end
      end

      def different?(key)
        extract_from(@old_data, key) != extract_from(@new_data, key)
      end

      def extract_from(hash, key_or_keys)
        hash.dig(*Array(key_or_keys).map(&:to_s))
      end
    end
  end
end
