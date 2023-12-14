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
          text: format_total(disbursement_total),
          footer: true
        },
        {
          head_key: 'total_inc_vat',
          text: format_total(disbursement_total_inc_vat)
        },
      ]
    end

    def disbursement_total_inc_vat
      disbursements.total_cost
    end

    def disbursement_total
      disbursements.disbursement_forms.filter_map(&:total_cost_pre_vat).sum
    end
  end
end
