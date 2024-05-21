module Nsm
  module Steps
    class LettersCallsForm < ::Steps::BaseFormObject
      include LettersAndCallsCosts
      attr_writer :apply_calls_uplift, :apply_letters_uplift

      attribute :letters, :integer
      attribute :calls, :integer
      attribute :letters_uplift, :integer
      attribute :calls_uplift, :integer

      validates :letters, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_blank: true }
      validates :calls, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_blank: true }
      validates :letters_uplift, presence: true,
        numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 100 },
        if: :apply_letters_uplift
      validates :calls_uplift, presence: true,
        numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 100 },
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
        [
          translate(:letters),
          {
            text: NumberTo.pounds(letters_before_uplift),
            html_attributes: { id: 'letters-without-uplift' }
          },
          (
            if allow_uplift?
              {
                text: NumberTo.pounds(letters_after_uplift),
                html_attributes: { id: 'letters-with-uplift' },
              }
            end
          )
        ]
      end

      def calls_row
        [
          translate(:calls),
          {
            text: NumberTo.pounds(calls_before_uplift),
            html_attributes: { id: 'calls-without-uplift' }
          },
          (
            if allow_uplift?
              {
                text: NumberTo.pounds(calls_after_uplift),
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
    end
  end
end
