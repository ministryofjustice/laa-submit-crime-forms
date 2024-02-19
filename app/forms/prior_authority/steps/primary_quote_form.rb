module PriorAuthority
  module Steps
    class PrimaryQuoteForm < ::Steps::BaseFormObject
      attribute :contact_full_name, :string
      attribute :organisation, :string
      attribute :postcode, :string

      validates :service_type_autocomplete, presence: true
      validates :contact_full_name, presence: true, format: { with: /\A[a-z,.'\-]+( +[a-z,.'\-]+)+\z/i }
      validates :organisation, presence: true
      validates :postcode, presence: true, uk_postcode: true

      # Using local variable for service_type_autocomplete to avoid issues with
      # assignment of value into two fields service_type and custom_service_name
      attr_accessor :service_type, :custom_service_name, :local_values

      def service_type_autocomplete
        scope = local_values ? self : application
        scope.service_type == 'custom' ? scope.custom_service_name : scope.service_type
      end

      def service_type_autocomplete_suggestion=(value)
        # used to ensure we use the right scope in validations
        self.local_values = true

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
        record.update!(attributes_to_update)
        application.update(service_type:, custom_service_name:) if service_type

        # If a change to service type has rendered any alternative quotes invalid,
        # delete them because we don't yet have a UI for highlighting invalidities
        # from the overview screen
        application.alternative_quotes
                   .reject { AlternativeQuotes::DetailForm.build(_1, application:).valid? }
                   .each(&:destroy)
      end

      def attributes_to_update
        attributes
          .except('service_type', 'custom_service_name')
          .merge('primary' => true)
      end

      def translations
        QuoteServices.values.to_h { [_1.translated, _1.value] }
      end
    end
  end
end
