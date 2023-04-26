class Solicitor < ApplicationRecord
  belongs_to :previous, optional: true, class_name: 'Solicitor'
  has_many :nexts, class_name: 'Solicitor', foreign_key: :previous_id, inverse_of: :previous, dependent: nil

  scope :latest, -> { left_joins(:nexts).where(nexts_solicitors: { id: nil }) }
end
