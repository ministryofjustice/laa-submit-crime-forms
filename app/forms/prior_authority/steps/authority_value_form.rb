module PriorAuthority
  module Steps
    class AuthorityValueForm < ::Steps::BaseFormObject
      attribute :authority_value, :boolean
      validate :authority_value_inclusion_with_threshold

      def persist!
        application.update!(attributes)
      end

      private

      def authority_value_inclusion_with_threshold
        return if authority_value.in?([true, false])

        if application.prison_law?
          errors.add(:authority_value, :'inclusion.less_than_five_hundred')
        else
          errors.add(:authority_value, :'inclusion.less_than_one_hundred')
        end
      end
    end
  end
end
