class Solicitor < ApplicationRecord
  has_many :nexts, class_name: 'Solicitor', foreign_key: :previous_id
  belongs_to :previous, optional: true, class_name: 'Solicitor'

  scope :latest, -> { left_joins(:nexts).where(nexts_solicitors: { id: nil }) }
end
