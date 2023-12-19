class Assignment < ApplicationRecord
  belongs_to :submitted_claim
  belongs_to :user

  validates :submitted_claim, uniqueness: true

  delegate :display_name, to: :user
end
