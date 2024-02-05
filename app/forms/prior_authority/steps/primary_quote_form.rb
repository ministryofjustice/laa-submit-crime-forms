module PriorAuthority
  module Steps
    class PrimaryQuoteForm < ::Steps::BaseFormObject
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
        if value.downcase.in?(translated_values)
          self.service_type = service_type_code(value)
          self.custom_service_name = nil
        else
          self.service_type = 'custom' if value.present?
          self.custom_service_name = value
        end
      end

      private

      def persist!
        record.update!(attributes.merge(default_attributes))
      end

      def default_attributes
        {
          'primary' => true
        }
      end

      def translated_values
        QuoteServices.values.map{|value| value.translated.downcase }
      end

      def service_type_code(service_type_string)
       I18n.t("helpers.quote_services").transform_values(&:downcase).key(service_type_string.downcase)
      end
    end
  end
end
