# frozen_string_literal: true

module CheckAnswers
  class DefendantCard < Base
    attr_reader :defendants, :maat_required

    def initialize(claim)
      @defendants = claim.defendants
      @group = 'about_defendant'
      @section = 'defendant_summary'
      @maat_required = claim.claim_type != ClaimType::BREACH_OF_INJUNCTION.to_s
    end

    def row_data
      main_defendant, *additional_defendants = *defendants

      generate_rows('main', main_defendant, 0) +
        additional_defendants.flat_map.with_index do |defendant, index|
          generate_rows('additional', defendant, index)
        end
    end

    private

    def generate_rows(key_prefix, defendant, index)
      rows = [
        {
          head_key: "#{key_prefix}_defendant_full_name",
          text: check_missing(defendant[:full_name]),
          head_opts: { count: index + 1 }
        }
      ]

      rows << {
        head_key: "#{key_prefix}_defendant_maat",
        text: check_missing(defendant[:maat]),
        head_opts: { count: index + 1 }
      } if maat_required

      rows
    end
  end
end
