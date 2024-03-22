class PriorAuthorityApplication < ApplicationRecord
  belongs_to :provider
  belongs_to :firm_office, optional: true
  belongs_to :solicitor, optional: true
  has_one :defendant, dependent: :destroy, as: :defendable
  has_many :quotes, dependent: :destroy
  has_one :primary_quote,
          -> { primary },
          class_name: 'Quote',
          dependent: :destroy,
          inverse_of: :prior_authority_application
  has_many :alternative_quotes,
           -> { alternative },
           class_name: 'Quote',
           dependent: :destroy,
           inverse_of: :prior_authority_application
  has_many :supporting_documents, -> { order(:created_at, :file_name).supporting_documents },
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
    rejected: 'rejected',
    auto_grant: 'auto_grant',
    part_grant: 'part_grant',
    sent_back: 'sent_back',
    provider_updated: 'provider_updated',
    expired: 'expired'
  }

  scope :reviewed, -> { where(status: %i[granted part_grant rejected auto_grant sent_back]) }

  scope :for, ->(provider) { where(office_code: provider.selected_office_code) }

  def youth_court_applicable?
    court_type == PriorAuthority::CourtTypeOptions::MAGISTRATE.to_s
  end

  def psychiatric_liaison_applicable?
    court_type == PriorAuthority::CourtTypeOptions::CENTRAL_CRIMINAL.to_s
  end

  def total_cost
    primary_quote&.total_cost
  end

  def total_cost_gbp
    total_cost ? NumberTo.pounds(total_cost) : nil
  end
end
