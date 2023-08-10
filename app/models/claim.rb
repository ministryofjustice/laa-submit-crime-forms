class Claim < ApplicationRecord
  belongs_to :submitter, class_name: 'Provider'
  belongs_to :firm_office, optional: true
  belongs_to :solicitor, optional: true
  has_many :defendants, -> { order(:position) }, dependent: :destroy, inverse_of: :claim
  has_one :main_defendant, -> { where(main: true) }, class_name: 'Defendant', dependent: nil, inverse_of: :claim
  has_many :work_items, -> { order(:completed_on, :work_type, :id) }, dependent: :destroy, inverse_of: :claim
  has_many :disbursements, lambda {
                             order(:disbursement_date, :disbursement_type, :id)
                           }, dependent: :destroy, inverse_of: :claim
  has_many :supporting_evidence, -> { order(:created_at, :file_name) }, dependent: :destroy, inverse_of: :claim

  scope :for, ->(provider) { where(office_code: providers.selected_office_code) }

  def date
    rep_order_date || cntp_date
  end

  def short_id
    id.first(8)
  end
end
