class Claim < ApplicationRecord
  def date
    rep_order_date || cntp_date
  end

  def short_id
    id.first(8)
  end
end
