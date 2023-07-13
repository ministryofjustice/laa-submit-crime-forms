class WorkItem < ApplicationRecord
  belongs_to :claim

  validates :id, exclusion: { in: [StartPage::NEW_RECORD] }
end
