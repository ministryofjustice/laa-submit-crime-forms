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
  has_many :further_informations, dependent: :destroy, inverse_of: :prior_authority_application
  has_many :incorrect_informations, dependent: :destroy, inverse_of: :prior_authority_application

  attribute :confirm_excluding_vat, :boolean
  attribute :confirm_travel_expenditure, :boolean

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

  scope :reviewed, -> { where(status: %i[granted part_grant rejected auto_grant sent_back expired]) }
  scope :submitted_or_resubmitted, -> { where(status: %i[submitted provider_updated]) }

  scope :for, ->(provider) { where(office_code: provider.office_codes).or(where(office_code: nil, provider: provider)) }

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
