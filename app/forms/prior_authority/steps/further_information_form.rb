module PriorAuthority
  module Steps
    class FurtherInformationForm < ::Steps::BaseFormObject
      attribute :information_supplied, :string

      validates :information_supplied, presence: true

      private

      def persist!
        record.update!(attributes)
      end
    end
  end
end
