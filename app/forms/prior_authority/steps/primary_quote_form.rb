module PriorAuthority
  module Steps
    class PrimaryQuoteForm < ::Steps::BaseFormObject
      def self.attribute_names
        super - %w[service_type custom_service_name]
      end

      def initialize(attrs)
        # We have logic to set these below if a service type suggestion is provided,
        # and we don't want the arbitrary order of attribute assignment to overwrite that
        if attrs.key?('service_type_suggestion')
          attrs.delete('service_type')
          attrs.delete('custom_service_name')
        else

          # This ensures that the 'service type suggestion' field in the UI is
          # is pre-populated with the custom name
          if attrs[:application].service_type == 'custom'
            attrs[:application].service_type = attrs[:application].custom_service_name
          end

          # But otherwise, we need to pull in application-wide settings to this quote-specific model
          attrs[:service_type] ||= attrs[:application].service_type
          attrs[:custom_service_name] ||= attrs[:application].custom_service_name
        end
        super(attrs)
      end

      attribute :service_type, :value_object, source: QuoteServices
      attribute :custom_service_name, :string
      attribute :contact_full_name, :string
      attribute :organisation, :string
      attribute :postcode, :string

      validates :service_type, presence: true
      validates :contact_full_name, presence: true, format: { with: /\A[a-z,.'\-]+( +[a-z,.'\-]+)+\z/i }
      validates :organisation, presence: true
      validates :postcode, presence: true, uk_postcode: true

      def service_type_suggestion=(value)
        # The value of service_type_suggestion is the contents of the visible text field, which is the translated value.
        # This is separate from the value of service_type which is the untranslated value, stored in a hidden dropdown.
        # The complication is that if a user types in a value to the text field but doesn't click the autocomplete,
        # service_type_suggestion will contain an accurate translated value, but service_type dropdown contains
        # a false untranslated value.
        # So to avoid being caught out, the translated value needs to take precedence, and we need to infer the
        # untranslated value from that.
        if value.in?(translations.keys)
          self.service_type = translations[value]
          self.custom_service_name = nil
        else
          self.service_type = 'custom' if value.present?
          self.custom_service_name = value
        end
      end

      def document
        # needed for primary quote summary presenter
        # can probably remove if we make a custom type for files and handle
        # upload via the form
        application.primary_quote.document
      end

      private

      def persist!
        record.update!(attributes.except('service_type', 'custom_service_name')
                                 .merge(default_attributes))
        application.update(service_type:, custom_service_name:)

        # If a change to service type has rendered any alternative quotes invalid,
        # delete them because we don't yet have a UI for highlighting invalidities
        # from the overview screen
        application.alternative_quotes
                   .reject { AlternativeQuotes::DetailForm.build(_1, application:).valid? }
                   .each(&:destroy)
      end

      def default_attributes
        {
          'primary' => true
        }
      end

      def translations
        QuoteServices.values.to_h { [_1.translated, _1.value] }
      end
    end
  end
end
