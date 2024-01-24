# NOTE: position value is used purely to maintain insertion order
# and is not used to number or identify the defendant.
class Defendant < ApplicationRecord
  belongs_to :claim

  validates :id, exclusion: { in: [Nsm::StartPage::NEW_RECORD] }
end
