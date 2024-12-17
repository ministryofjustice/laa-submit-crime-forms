class Solicitor < ApplicationRecord
  has_one :prior_authority_applications, dependent: :destroy
  has_one :claims, dependent: :destroy

  def contact_full_name
    "#{contact_first_name} #{contact_last_name}"
  end
end
