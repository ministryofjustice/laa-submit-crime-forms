module PriorAuthority
  module Steps
    class PrimaryQuoteForm < ::Steps::BaseFormObject
      attribute :service_name, :string
      attribute :contact_full_name, :string
      attribute :organisation, :string
      attribute :postcode, :string

      validates :service_name, presence: true
      validates :contact_full_name, presence: true
      validates :organisation, presence: true
      validates :postcode, presence: true, uk_postcode: true

      private

      def persist!
        record.update!(attributes.merge(attributes_to_reset))
      end

      def attributes_to_reset
        {
          'primary' => true
        }
      end
    end
  end
end
