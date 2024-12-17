class FirmOffice < ApplicationRecord
  has_many :prior_authority_applications, dependent: :destroy
end
