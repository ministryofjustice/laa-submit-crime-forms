# NOTE: position value is used purely to maintain insertion order
# and is not used to number or identify the defendant.
class Defendant < ApplicationRecord
  belongs_to :claim
  belongs_to :prior_authority_application

  validates :id, exclusion: { in: [StartPage::NEW_RECORD] }
end
