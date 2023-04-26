class FirmOffice < ApplicationRecord
  has_many :nexts, class_name: 'FirmOffice', foreign_key: :previous_id
  belongs_to :previous, optional: true, class_name: 'FirmOffice'

  scope :latest, -> { left_joins(:nexts).where(nexts_firm_offices: { id: nil }) }
end
