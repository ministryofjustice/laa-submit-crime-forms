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
      [
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
        {
          head_key: 'preparation_time',
          text: process_field(boolean_field: claim.preparation_time, value_field: claim.time_spent) do
            ApplicationController.helpers.format_period(claim.time_spent)
          end
        },
        {
          head_key: 'work_before',
          text: process_field(boolean_field: claim.work_before, value_field: claim.work_before_date) do
            claim.work_before_date.strftime('%d %B %Y')
          end
        },
        {
          head_key: 'work_after',
          text: process_field(boolean_field: claim.work_after, value_field: claim.work_after_date) do
            claim.work_after_date.strftime('%d %B %Y')
          end
        },
      ]
    end
    # rubocop:enable Metrics/AbcSize

    def process_field(boolean_field:, value_field:, &value_formatter)
      result = check_missing(boolean_field.present?) do
        values = [boolean_field.capitalize]

        values << check_missing(value_field, &value_formatter) if boolean_field == YesNoAnswer::YES.to_s

        values.compact.join(' - ')
      end

      ApplicationController.helpers.sanitize(result, tags: %w[strong])
    end
  end
end
