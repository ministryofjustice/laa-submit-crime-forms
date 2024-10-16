module Nsm
  module Steps
    class WorkItemForm < ::Steps::AddAnotherForm
      include WorkItemCosts
      attr_writer :apply_uplift

      attribute :work_type, :value_object, source: WorkTypes
      attribute :time_spent, :time_period
      attribute :completed_on, :multiparam_date
      attribute :fee_earner, :string
      attribute :uplift, :fully_validatable_integer

      validates :work_type, presence: true, inclusion: { in: WorkTypes.values }
      validate :work_type_allowed
      validates :time_spent, presence: true, time_period: true
      validates :completed_on, presence: true,
              multiparam_date: { allow_past: true, allow_future: false }
      validates :fee_earner, presence: true
      validates :uplift,
                presence: true,
                # allow_blank here, while technically redundant, makes explicit that when the field is blank,
                # it will be the `presence` validation that fails, not the `numericality` one
                numericality: { allow_blank: true, only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 100 },
                is_a_number: true,
                if: :apply_uplift

      def work_types_with_pricing
        WorkTypes.values.filter_map do |work_type|
          [work_type, pricing[work_type.to_s]] if work_type.display?(application)
        end
      end

      # rubocop:disable Metrics/MethodLength
      def calculation_rows
        if allow_uplift?
          [
            [translate(:before_uplift), translate(:after_uplift)],
            [
              {
                text: NumberTo.pounds(total_without_uplift),
                html_attributes: { id: 'without-uplift' }
              },
              {
                text: NumberTo.pounds(total_cost),
                html_attributes: { id: 'with-uplift' },
              }
            ]
          ]
        else
          [
            [translate(:total)],
            [
              {
                text: NumberTo.pounds(total_without_uplift),
                html_attributes: { id: 'without-uplift' }
              }
            ]
          ]
        end
      end
      # rubocop:enable Metrics/MethodLength

      private

      def persist!
        record.id = nil if record.id == StartPage::NEW_RECORD
        record.update!(attributes_with_resets)
      end

      def attributes_with_resets
        attributes.merge('uplift' => apply_uplift ? uplift : 0)
      end

      def translate(key)
        I18n.t("nsm.steps.work_item.edit.#{key}")
      end

      def work_type_allowed
        return unless work_type
        return if WorkTypes::VALUES.detect { _1 == work_type }.display?(application)

        errors.add(:work_type, :inclusion)
      end
    end
  end
end
