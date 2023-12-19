module Assess
  module V1
    class LettersAndCallsSummary < Assess::BaseViewModel
      attribute :claim

      def summary_row
        [
          rows.sum(&:count).to_s,
          '-',
          NumberTo.pounds(rows.sum(&:provider_requested_amount)),
          '-',
          NumberTo.pounds(rows.sum(&:allowed_amount))
        ]
      end

      def rows
        @rows ||= BaseViewModel.build(:letter_and_call, claim, 'letters_and_calls')
      end

      def uplift?
        rows.any? { |row| row.uplift&.positive? }
      end
    end
  end
end
