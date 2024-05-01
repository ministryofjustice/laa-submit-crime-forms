module PriorAuthority
  module Steps
    class OfficeCodeForm < ::Steps::BaseFormObject
      attribute :office_code, :string

      validates :office_code, inclusion: { in: :options, allow_blank: false }

      def options
        application.provider.office_codes
      end

      private

      def persist!
        application.update!(attributes)
      end
    end
  end
end
