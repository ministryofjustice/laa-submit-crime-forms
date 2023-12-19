module Assess
  class DisbursementsForm < BaseAdjustmentForm
    LINKED_CLASS = V1::Disbursement
    DISBURSEMENT_ALLOWED = 'no'.freeze
    DISBURSEMENT_REFUSED = 'yes'.freeze

    attribute :total_cost_without_vat, :string
    validates :total_cost_without_vat, inclusion: { in: [DISBURSEMENT_ALLOWED, DISBURSEMENT_REFUSED] }

    def total_cost_without_vat=(val)
      case val
      when String then super
      when nil then nil
      else
        super(val.positive? ? 'no' : 'yes')
      end
    end

    def save
      return false unless valid?

      SubmittedClaim.transaction do
        process_field(value: new_total_cost_without_vat, field: 'total_cost_without_vat')
        process_field(value: new_vat_amount, field: 'vat_amount')
        claim.save
      end

      true
    end

    private

    def selected_record
      @selected_record ||= claim.data['disbursements'].detect do |row|
        row.fetch('id') == item.id
      end
    end

    def new_total_cost_without_vat
      total_cost_without_vat == 'yes' ? 0 : item.provider_requested_total_cost_without_vat
    end

    def new_vat_amount
      total_cost_without_vat == 'yes' ? 0 : item.provider_requested_vat_amount
    end

    def data_has_changed?
      item.total_cost_without_vat.zero? != (total_cost_without_vat == DISBURSEMENT_REFUSED)
    end

    def explanation_required?
      super && total_cost_without_vat == DISBURSEMENT_REFUSED
    end
  end
end
