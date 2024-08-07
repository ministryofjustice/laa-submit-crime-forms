class Disbursement < ApplicationRecord
  belongs_to :claim

  include DisbursementCosts

  validates :id, exclusion: { in: [Nsm::StartPage::NEW_RECORD] }

  scope :by_age, -> { reorder(:disbursement_date, :created_at) }

  def as_json(*)
    super.merge(
      'disbursement_type' => translations(disbursement_type,
                                          'helpers.label.nsm_steps_disbursement_type_form.disbursement_type_options'),
      'other_type' => translations(other_type, 'helpers.other_disbursement_type')
    )
  end

  def translated_disbursement_type
    if disbursement_type == DisbursementTypes::OTHER.to_s
      known_other = OtherDisbursementTypes.values.include?(OtherDisbursementTypes.new(other_type))
      return translate("other.#{other_type}") if known_other

      other_type
    elsif disbursement_type
      translate("standard.#{disbursement_type}")
    end
  end

  def position
    super || claim.disbursement_position(self)
  end

  private

  def translate(key, **)
    I18n.t("summary.nsm/cost_summary/disbursements.#{key}", **)
  end
end
