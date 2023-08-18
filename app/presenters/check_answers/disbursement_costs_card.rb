# frozen_string_literal: true

module CheckAnswers
  class DisbursementCostsCard < Base
    attr_reader :claim, :disbursements

    def initialize(claim)
      @claim = claim
      @disbursements = CostSummary::Disbursements.new(claim.disbursements.by_age, claim)
      @section = 'disbursements'
      @group = 'about_claim'
    end

    def row_data
      header_rows + disbursement_rows + total_rows
    end

    def as_json(*)
      claim.disbursements.map do |disbursement|
        data = disbursement.attributes.slice!('claim_id', 'created_at', 'updated_at')
        data['completed_on'] = data['completed_on'].to_s
        data
      end
    end

    private

    def header_rows
      [
        {
          head_key: 'items',
          text: ApplicationController.helpers.sanitize(translate_table_key(section, 'items_total'), tags: %w[strong])
        }
      ]
    end

    def disbursement_rows
      disbursements.rows.map do |row|
        {
          head_key: row[:key][:text],
          text: row[:value][:text]
        }
      end
    end

    def total_rows
      [
        {
          head_key: 'total',
          text: disbursement_total,
          footer: true
        }
      ]
    end

    def disbursement_total
      NumberTo.pounds(disbursements.total_cost)
    end
  end
end
