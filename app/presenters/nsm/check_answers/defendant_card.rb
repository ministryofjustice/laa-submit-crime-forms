# frozen_string_literal: true

module Nsm
  module CheckAnswers
    class DefendantCard < Base
      attr_reader :main_defendant, :additional_defendants, :maat_required

      def initialize(claim)
        @claim = claim
        @main_defendant = claim.main_defendant
        @additional_defendants = claim.defendants.where(main: false)
        @group = 'about_defendant'
        @section = 'defendant_summary'
        @maat_required = claim.claim_type != ClaimType::BREACH_OF_INJUNCTION.to_s
      end

      def row_data
        [generate_row('main', main_defendant || Defendant.new, 0)] +
          additional_defendants.each.with_index.map do |defendant, index|
            generate_row('additional', defendant, index)
          end
      end

      private

      def generate_row(key_prefix, defendant, index)
        {
          head_key: "#{key_prefix}_defendant",
          text: text(defendant),
          head_opts: { count: index + 2 }
        }
      end

      def text(defendant)
        if defendant.first_name.blank? || defendant.last_name.blank? || (maat_required && defendant.maat.blank?)
          missing_tag
        elsif maat_required
          safe_join([defendant.full_name, tag.br, defendant.maat])
        else
          defendant.full_name
        end
      end
    end
  end
end
