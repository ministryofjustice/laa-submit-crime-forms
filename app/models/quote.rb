class Quote < ApplicationRecord
  belongs_to :prior_authority_application

  scope :alternative, -> { where(primary: false) }
end
