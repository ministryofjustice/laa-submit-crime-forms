# this is a form to determine where to move to the equality questions
# or skip them, as such it does not persist anything to DB
module Nsm
  module Steps
    class EqualityQuestionsForm < ::Steps::BaseFormObject
      attribute :gender, :value_object, source: Genders
      attribute :ethnic_group, :value_object, source: EthnicGroups
      attribute :disability, :value_object, source: Disabilities

      validates :gender, inclusion: { in: Genders.values, allow_blank: true }
      validates :ethnic_group, inclusion: { in: EthnicGroups.values, allow_blank: true }
      validates :disability, inclusion: { in: Disabilities.values, allow_blank: true }

      private

      def persist!
        application.update!(attributes)
      end
    end
  end
end
