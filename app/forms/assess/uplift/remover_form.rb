# Special form to process each row/record when running the
# remove uplift from all processing. It requires the `LINKED_CLASS`
# constant to be set in the subclass to work.
module Assess
  module Uplift
    class RemoverForm < BaseAdjustmentForm
      attribute :selected_record

      def save
        process_field(value: 0, field: 'uplift')
      end

      private

      def data_changed
        return if data_has_changed?

        errors.add(:base, :no_change)
      end

      def data_has_changed?
        selected_record['uplift']&.positive?
      end
    end
  end
end
