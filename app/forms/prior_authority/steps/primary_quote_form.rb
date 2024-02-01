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
        if value.in?(translated_values)
          self.service_type = service_type.value
          self.custom_service_name = nil
        else
          self.service_type = 'custom'
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
        QuoteServices.values.map(&:translated)
      end
    end
  end
end
