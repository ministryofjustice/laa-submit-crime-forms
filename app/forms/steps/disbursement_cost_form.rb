require 'steps/base_form_object'

module Steps
  class DisbursementCostForm < Steps::BaseFormObject
    attr_writer :apply_vat

    attribute :miles, :integer
    attribute :total_cost_without_vat, :decimal, precision: 10, scale: 2
    attribute :details, :string
    attribute :prior_authority, :value_object, source: YesNoAnswer

    validates :miles, presence: true, numericality: { greater_than: 1 }, unless: :other_disbursement_type?
    validates :total_cost_without_vat, presence: true, numericality: { greater_than: 1 }, if: :other_disbursement_type?
    validates :details, presence: true
    validates :prior_authority, presence: true, inclusion: { in: YesNoAnswer.values }, if: :auth_required?

    def other_disbursement_type?
      record.disbursement_type == DisbursementTypes::OTHER.to_s
    end

    def apply_vat
      @apply_vat.nil? ? record.vat_amount.present? : @apply_vat == 'true'
    end

    private

    def persist!
      record.update!(attributes_with_resets)
    end

    def attributes_with_resets
      # debugger
      attributes.merge(
        miles: other_disbursement_type? ? nil : miles,
        total_cost_without_vat: total_cost,
        vat_amount: apply_vat && total_cost ? total_cost * vat_rate : 0.0,
      )
    end

    def total_cost
      @total_cost ||= if other_disbursement_type?
                        total_cost_without_vat
                      elsif miles
                        miles.to_f * pricing[record.disbursement_type]
                      end
    end

    def auth_required?
      total_cost && total_cost >= 100
    end

    def pricing
      @pricing ||= Pricing.for(application)
    end

    def vat_rate
      pricing[:vat]
    end
  end
end
