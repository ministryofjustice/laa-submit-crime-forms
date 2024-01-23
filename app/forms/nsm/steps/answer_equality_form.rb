# this is a form to determine where to move to the equality questions
# or skip them, as such it does not persist anything to DB
module Nsm
  module Steps
    class AnswerEqualityForm < ::Steps::BaseFormObject
      attribute :answer_equality, :value_object, source: YesNoAnswer

      validates :answer_equality, presence: true, inclusion: { in: YesNoAnswer.values }

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        application.update!(attributes)
      end
    end
  end
end
