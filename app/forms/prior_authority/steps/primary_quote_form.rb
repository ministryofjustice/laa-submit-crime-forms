module PriorAuthority
  module Steps
    class PrimaryQuoteForm < ::Steps::BaseFormObject
      attribute :service_type, :value_object, source: QuoteServices
      attribute :contact_full_name, :string
      attribute :organisation, :string
      attribute :postcode, :string

      validates :service_type, presence: true
      validates :contact_full_name, presence: true, format: { with: /\A[a-z,.'\-]+( +[a-z,.'\-]+)+\z/i }
      validates :organisation, presence: true
      validates :postcode, presence: true, uk_postcode: true

      def service_type_suggestion=(value)
        return if service_type && QuoteServices.new(service_type).translated == value

        self.service_type = value
      end

      private

      def persist!
        record.update!(attributes_with_resets.merge(default_attributes))
      end

      def default_attributes
        {
          'primary' => true
        }
      end

      def attributes_with_resets
        attributes.merge('custom_service_name' => custom_service? ? service_type : nil)
      end

      def custom_service?
        service_type.in? QuoteServices.values
      end
    end
  end
end
