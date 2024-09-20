class Disbursement < ApplicationRecord
  belongs_to :claim

  include DisbursementCosts

  validates :id, exclusion: { in: [Nsm::StartPage::NEW_RECORD] }

  scope :by_age, -> { reorder(:disbursement_date, :created_at) }

  def translated_disbursement_type
    if disbursement_type == DisbursementTypes::OTHER.to_s
      known_other = OtherDisbursementTypes.values.include?(OtherDisbursementTypes.new(other_type))
      return I18n.t("laa_crime_forms_common.nsm.other_disbursement_type.#{other_type}") if known_other

      other_type
    elsif disbursement_type
      I18n.t("laa_crime_forms_common.nsm.disbursement_type.#{disbursement_type}")
    end
  end

  def position
    super || claim.disbursement_position(self)
  end
end
