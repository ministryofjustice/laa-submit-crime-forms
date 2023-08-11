# frozen_string_literal: true

module CheckAnswers
  class ClaimDetailsCard < Base
    attr_reader :claim

    def initialize(claim)
      @claim = claim
      @group = 'about_claim'
      @section = 'claim_details'
    end

    # rubocop:disable Metrics/AbcSize
    def row_data
      data = [
        {
          head_key: 'prosecution_evidence',
          text: check_missing(claim.prosecution_evidence)
        },
        {
          head_key: 'defence_statement',
          text: check_missing(claim.defence_statement)
        },
        {
          head_key: 'number_of_witnesses',
          text: check_missing(claim.number_of_witnesses)
        },
        {
          head_key: 'supplemental_claim',
          text: check_missing(claim.supplemental_claim.present?) do
            claim.supplemental_claim.capitalize
          end
        },
        process_boolean_value(boolean_field: claim.preparation_time, value_field: claim.time_spent, boolean_key: 'preparation_time', value_key: 'time_spent') do
          ApplicationController.helpers.format_period(claim.time_spent)
        end
      ].flatten
    end
    # rubocop:enable Metrics/AbcSize
  end
end
