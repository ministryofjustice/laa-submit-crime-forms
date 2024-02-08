class PriorAuthorityApplication < ApplicationRecord
  belongs_to :provider
  belongs_to :firm_office, optional: true
  belongs_to :solicitor, optional: true
  has_one :defendant, dependent: :destroy, as: :defendable
  has_many :quotes, dependent: :destroy
  has_one :primary_quote, lambda {
                            where(primary: true)
                          }, class_name: 'Quote', dependent: :destroy, inverse_of: :prior_authority_application
  has_many :supporting_documents, -> { order(:created_at, :file_name).supporting_documents },
           dependent: :destroy,
                    inverse_of: :documentable,
                    class_name: 'SupportingDocument',
                    as: :documentable
  has_one :primary_quote_document, lambda {
                                     where(document_type: SupportingDocument::PRIMARY_QUOTE_DOCUMENT)
                                   },
           dependent: :destroy,
           inverse_of: :documentable,
           class_name: 'SupportingDocument',
           as: :documentable
  has_many :additional_costs, dependent: :destroy

  attribute :prison_law, :boolean
  attribute :ufn, :string
  attribute :office_code, :string
  attribute :contact_name, :string
  attribute :contact_email, :string
  attribute :firm_name, :string
  attribute :firm_account_number, :string
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  enum :status, {
    pre_draft: 'pre_draft',
    draft: 'draft',
    submitted: 'submitted',
    granted: 'granted',
    part_granted: 'part_granted',
    rejected: 'rejected'
  }

  scope :assessed, -> { where(status: %w[granted part_granted rejected]) }

  scope :for, ->(provider) { where(office_code: provider.selected_office_code) }
end
