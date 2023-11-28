module Steps
  module Office
    class ConfirmForm < Steps::BaseFormObject
      attribute :is_current_office, :value_object, source: YesNoAnswer
      validates :is_current_office, inclusion: { in: :choices }

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        true
      end
    end
  end
end
