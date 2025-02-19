class Disbursement < ApplicationRecord
  belongs_to :claim

  include DisbursementDetails

  validates :id, exclusion: { in: [Nsm::StartPage::NEW_RECORD] }

  scope :by_age, -> { reorder(:disbursement_date, :created_at) }

  def position
    super || claim.disbursement_position(self)
  end

  def imported?
    self.created_at < current_application.import_date
  end
end
