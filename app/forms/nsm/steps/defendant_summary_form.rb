module Nsm
  module Steps
    class DefendantSummaryForm < ::Steps::AddAnotherForm
      def save
        unless defendants.all?(&:valid?)
          errors.add(:add_another, :invalid_item)
          return false
        end

        super
      end

      def defendants
        @defendants ||= application.defendants.map do |defendant|
          DefendantDetailsForm.build(defendant, application:)
        end
      end
    end
  end
end
