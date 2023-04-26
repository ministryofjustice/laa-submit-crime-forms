class FirmOffice < ApplicationRecord
  belongs_to :previous, optional: true, class_name: 'FirmOffice'
  has_many :nexts, class_name: 'FirmOffice', foreign_key: :previous_id, inverse_of: :previous, dependent: nil

  scope :latest, -> { left_joins(:nexts).where(nexts_firm_offices: { id: nil }) }
end
