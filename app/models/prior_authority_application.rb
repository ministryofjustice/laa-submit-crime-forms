class PriorAuthorityApplication < ApplicationRecord
  belongs_to :provider
  belongs_to :firm_office, optional: true
  belongs_to :solicitor, optional: true
  has_one :defendant, dependent: :destroy, as: :defendable

  attribute :prison_law, :boolean
  attribute :ufn, :string
  attribute :office_code, :string
  attribute :contact_name, :string
  attribute :contact_email, :string
  attribute :firm_name, :string
  attribute :firm_account_number, :string
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  enum :status, { pre_draft: 'pre_draft', draft: 'draft', submitted: 'submitted' }

  scope :for, ->(provider) { where(office_code: provider.selected_office_code) }
end
