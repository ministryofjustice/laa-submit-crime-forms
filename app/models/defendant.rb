# NOTE: position value is used purely to maintain insertion order
# and is not used to number or identify the defendant.
class Defendant < ApplicationRecord
  belongs_to :defendable, polymorphic: true

  validates :id, exclusion: { in: [Nsm::StartPage::NEW_RECORD] }

  def full_name
    [first_name, last_name].join(' ')
  end

  def complete?
    Nsm::Steps::DefendantDetailsForm.build(self, application: defendable).valid?
  end
end
