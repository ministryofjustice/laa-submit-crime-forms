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

      def main_defendant
        @main_defendant ||= defendants.detect(&:main_record?)
      end

      def additional_defendants
        @additional_defendants ||= defendants.reject(&:main_record?)
      end

      def defendants
        @defendants ||= application.defendants.map do |defendant|
          DefendantDetailsForm.build(defendant, application:)
        end
      end
    end
  end
end
