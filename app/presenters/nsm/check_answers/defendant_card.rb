# frozen_string_literal: true

module Nsm
  module CheckAnswers
    class DefendantCard < Base
      attr_reader :main_defendant, :additional_defendants, :maat_required

      def initialize(claim)
        @main_defendant, *@additional_defendants = *claim.defendants
        @group = 'about_defendant'
        @section = 'defendant_summary'
        @maat_required = claim.claim_type != ClaimType::BREACH_OF_INJUNCTION.to_s
      end

      def row_data
        generate_rows('main', main_defendant || Defendant.new, 0) +
          additional_defendants.flat_map.with_index do |defendant, index|
            generate_rows('additional', defendant, index)
          end
      end

      private

      def generate_rows(key_prefix, defendant, index)
        data = [row(key_prefix, :first_name, defendant, index),
                row(key_prefix, :last_name, defendant, index)]

        data << row(key_prefix, :maat, defendant, index) if maat_required

        data
      end

      def row(key_prefix, key_suffix, defendant, index)
        {
          head_key: "#{key_prefix}_defendant_#{key_suffix}",
          text: check_missing(defendant[key_suffix]),
          head_opts: { count: index + 1 }
        }
      end
    end
  end
end
