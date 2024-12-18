class FirmOffice < ApplicationRecord
  has_one :prior_authority_applications, dependent: :destroy
  has_one :claims, dependent: :destroy
end
