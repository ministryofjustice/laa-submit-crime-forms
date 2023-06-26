require 'steps/base_form_object'

module Steps
  class DisbursementCostForm < Steps::BaseFormObject
    attribute :miles, :integer
    attribute :total_cost_without_vat, :decimal, precision: 2
    attribute :details, :string
    attribute :prior_authority, :value_object, source: YesNoAnswer
    attribute :apply_vat, :value_object, source: YesNoAnswer

    validates :miles, presence: true, numericality: { greater_than: 1 }, unless: :other_disbursement_type?
    validates :total_cost, presence: true, numericality: { greater_than: 1 }, if: :other_disbursement_type?
    validates :details, presence: true
    validates :prior_authority, presence: true, inclusion: { in: YesNoAnswer.values }, if: :auth_required?
    validates :apply_vat, presence: true, inclusion: { in: YesNoAnswer.values }

    def other_disbursement_type?
      record.disbursement_type == DisbursementTypes::OTHER.to_s
    end

    private

    def persist!
      record.update!(attributes_with_resets)
    end

    def attributes_with_resets
      attributes.merge(
        miles: other_disbursement_type? ? nil : miles,
        total_cost_without_vat: total_cost,
        vat_amount: apply_vat == YesNoAnswer::YES ? total_cost_without_vat * vat_rate : nil,
      )
    end

    def total_cost
      return total_cost_without_vat if other_disbursement_type?
      miles ? miles * rate : nil
    end

    def auth_required?
      total_cost && total_cost > 100
    end

    # TODO: add these to pricing object? or similar...
    def rate
      {
        'car' => 0.45,
        'motorcycle' => 0.45,
        'bike' => 0.25
      }[record.disbursement_type]
    end

    def vat_rate
      0.2
    end
  end
end
