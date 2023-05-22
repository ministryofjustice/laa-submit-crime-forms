class Claim < ApplicationRecord
  belongs_to :firm_office, optional: true
  belongs_to :solicitor, optional: true
  has_many :defendants, dependent: :destroy
  accepts_nested_attributes_for :defendants, allow_destroy: true

  def reference
    'aaaaa'
  end

  def date
    rep_order_date || cntp_date
  end

  def short_id
    id.first(8)
  end
end
