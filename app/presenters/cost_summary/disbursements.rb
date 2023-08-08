module CostSummary
  class Disbursements < Base
    TRANSLATION_KEY = self
    attr_reader :disbursement_forms, :claim

    def initialize(disbursements, claim)
      @claim = claim
      @disbursement_forms = disbursements.map do |disbursement|
        Steps::DisbursementCostForm.build(disbursement, application: claim)
      end
    end

    def rows
      disbursement_forms.map do |form|
        {
          key: { text: translated_text(form), classes: 'govuk-summary-list__value-width-50' },
          value: { text: NumberTo.pounds(form.total_cost) },
        }
      end
    end

    def total_cost
      @total_cost ||= disbursement_forms.filter_map(&:total_cost).sum
    end

    def title
      translate('disbursements', total: NumberTo.pounds(total_cost))
    end

    private

    def translated_text(form)
      # other_type is only populated for the `other` disbursement type
      if form.record.other_type.present?
        known_other = OtherDisbursementTypes.values.include?(OtherDisbursementTypes.new(form.record.other_type))
        return translate("other.#{form.record.other_type}") if known_other

        check_missing(form.record.other_type)
      else
        check_missing(form.record.disbursement_type.present?) do
          translate("standard.#{form.record.disbursement_type}")
        end
      end
    end
  end
end
