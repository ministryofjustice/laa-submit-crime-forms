class Disbursement < ApplicationRecord
  belongs_to :claim

  include DisbursementDetails

  validates :id, exclusion: { in: [Nsm::StartPage::NEW_RECORD] }

  scope :by_age, -> { reorder(:disbursement_date, :created_at) }

  def position
    super || claim.disbursement_position(self)
  end
end
