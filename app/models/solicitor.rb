class Solicitor < ApplicationRecord
  def contact_full_name
    "#{contact_first_name} #{contact_last_name}"
  end
end
