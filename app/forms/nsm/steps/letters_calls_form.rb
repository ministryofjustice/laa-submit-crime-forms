module Nsm
  module Steps
    class LettersCallsForm < ::Steps::BaseFormObject
      include LettersAndCallsCosts
      attr_writer :apply_calls_uplift, :apply_letters_uplift

      delegate :rates, to: :application

      attribute :letters, :fully_validatable_integer
      attribute :calls, :fully_validatable_integer
      attribute :letters_uplift, :fully_validatable_integer
      attribute :calls_uplift, :fully_validatable_integer

      validates :letters, is_a_number: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_blank: true }
      validates :calls, is_a_number: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_blank: true }
      validate :zero_letters_uplift_applied
      validates :letters_uplift, presence: true,
        is_a_number: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 100 },
        if: :apply_letters_uplift
      validate :zero_calls_uplift_applied
      validates :calls_uplift, presence: true,
        is_a_number: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 100 },
        if: :apply_calls_uplift

      def calculation_rows
        [header_row, letters_row, calls_row]
      end

      private

      def header_row
        if allow_uplift?
          [translate(:items), translate(:before_uplift),
           translate(:after_uplift)]
        else
          [translate(:items), translate(:total)]
        end
      end

      def letters_row
        letters_before = letters_before_uplift if letters.presence
        letters_after = letters_after_uplift if letters.presence
        [
          translate(:letters),
          {
            text: NumberTo.pounds(letters_before),
            html_attributes: { id: 'letters-without-uplift' }
          },
          (
            if allow_uplift?
              {
                text: NumberTo.pounds(letters_after),
                html_attributes: { id: 'letters-with-uplift' },
              }
            end
          )
        ]
      end

      def calls_row
        calls_before = calls_before_uplift if calls.presence
        calls_after = calls_after_uplift if calls.presence
        [
          translate(:calls),
          {
            text: NumberTo.pounds(calls_before),
            html_attributes: { id: 'calls-without-uplift' }
          },
          (
            if allow_uplift?
              {
                text: NumberTo.pounds(calls_after),
                html_attributes: { id: 'calls-with-uplift' },
              }
            end
          )
        ]
      end

      def translate(key)
        I18n.t("nsm.steps.letters_calls.edit.#{key}")
      end

      def persist!
        application.update!(attributes_with_resets)
      end

      def attributes_with_resets
        attributes.merge(
          'letters' => letters.presence || 0,
          'calls' => calls.presence || 0,
          'letters_uplift' => apply_letters_uplift ? letters_uplift : nil,
          'calls_uplift' => apply_calls_uplift ? calls_uplift : nil,
        )
      end

      def zero_letters_uplift_applied
        errors.add(:letters_uplift, :uplift_on_zero) if apply_letters_uplift && letters.to_i.zero?
      end

      def zero_calls_uplift_applied
        errors.add(:calls_uplift, :uplift_on_zero) if apply_calls_uplift && calls.to_i.zero?
      end
    end
  end
end
