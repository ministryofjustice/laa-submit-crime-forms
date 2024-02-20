module PriorAuthority
  module Steps
    class PrimaryQuoteForm < ::Steps::BaseFormObject
      def self.attribute_names
        super - %w[service_type custom_service_name file_upload]
      end
      attribute :contact_full_name, :string
      attribute :organisation, :string
      attribute :postcode, :string

      validates :service_type_autocomplete, presence: true
      validates :contact_full_name, presence: true, format: { with: /\A[a-z,.'\-]+( +[a-z,.'\-]+)+\z/i }
      validates :organisation, presence: true
      validates :postcode, presence: true, uk_postcode: true
      include DocumentUploadable # Include this here so that validations appear in the correct order

      # Using local variable for service_type_autocomplete to avoid issues with
      # assignment of value into two fields service_type and custom_service_name
      attr_accessor :service_type, :custom_service_name, :local_values

      def service_type_autocomplete
        scope = local_values ? self : application
        scope.service_type == 'custom' ? scope.custom_service_name : scope.service_type
      end

      # this should only be used when JS is disabled - otherwise overwritten by service_type_autocomplete_suggestion
      def service_type_autocomplete=(value)
        # ensure that is the suggestion is set first it cannot be overwritten
        return if local_values

        # used to ensure we use the right scope in validations
        self.local_values = true

        self.service_type = value
        self.custom_service_name = nil
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
        record.document || record.build_document
      end

      private

      def persist!
        return false unless save_file

        save_quote
        application.update(service_type:, custom_service_name:) if service_type

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

      def save_quote
        record.update!(attributes.except('service_type', 'custom_service_name', 'file_upload')
                                 .merge(default_attributes))
      end
    end
  end
end
