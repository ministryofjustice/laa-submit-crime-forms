module Nsm
  module Steps
    class ClaimTypeForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveRecord::AttributeAssignment

      attribute :claim_type, :value_object, source: ClaimType

      validates_inclusion_of :claim_type, in: :choices

      def choices
        ClaimType.values
      end
    end
  end
end
