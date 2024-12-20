class FirmOffice < ApplicationRecord
  has_one :prior_authority_application, dependent: :destroy
  has_one :claim, dependent: :destroy
end
