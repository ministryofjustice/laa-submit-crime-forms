class Solicitor < ApplicationRecord
  has_one :prior_authority_application, dependent: :destroy
  has_one :claim, dependent: :destroy

  def contact_full_name
    "#{contact_first_name} #{contact_last_name}"
  end
end
