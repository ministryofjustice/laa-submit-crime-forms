class Disbursement < ApplicationRecord
  belongs_to :claim

  validates :id, exclusion: { in: [StartPage::NEW_RECORD] }

  scope :by_age, -> { order(:disbursement_date, :created_at) }

  def total_cost
    return unless total_cost_without_vat && vat_amount

    total_cost_without_vat + vat_amount
  end

  def as_json(*)
    super.merge(
      'disbursement_type' => translations(disbursement_type, 'helpers.label.steps_disbursement_type_form.disbursement_type_options'),
      'other_type' => translations(other_type, 'helpers.other_disbursement_type')
    )
  end
end
