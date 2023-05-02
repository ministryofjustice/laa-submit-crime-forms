class Claim < ApplicationRecord
  belongs_to :firm_office, optional: true
  belongs_to :solicitor, optional: true

  def date
    rep_order_date || cntp_date
  end

  def short_id
    id.first(8)
  end
end
