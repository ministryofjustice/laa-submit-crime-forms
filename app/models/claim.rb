class Claim < ApplicationRecord
  belongs_to :firm_office, optional: true
  belongs_to :solicitor, optional: true
  has_many :defendants, -> { order(:position) }, dependent: :destroy, inverse_of: :claim
  has_many :work_items, dependent: :destroy, inverse_of: :claim

  def reference
    ufn || '###'
  end

  def date
    rep_order_date || cntp_date
  end

  def short_id
    id.first(8)
  end
end
