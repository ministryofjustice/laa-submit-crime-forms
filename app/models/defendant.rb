# NOTE: position value is used purely to maintain insertion order
# and is not used to number or identify the defendant.
class Defendant < ApplicationRecord
  belongs_to :claim, optional: true
  belongs_to :prior_authority_application, optional: true

  validates :id, exclusion: { in: [StartPage::NEW_RECORD] }
  validates :has_parent

  def has_parent
    if claim_id + prior_authority_application_id.nil?
      errors.add "needs at least one parent"
    end
  end
end
