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

  enum :state, {
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

  scope :reviewed, -> { where(state: %i[granted part_grant rejected auto_grant sent_back expired]) }
  scope :submitted_or_resubmitted, -> { where(state: %i[submitted provider_updated]) }

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

  def further_information_needed?
    pending_further_information.present?
  end

  def correction_needed?
    pending_incorrect_information.present?
  end

  def pending_further_information
    further_informations.where(created_at: app_store_updated_at..).order(:created_at).last
  end

  def pending_incorrect_information
    incorrect_informations.where(created_at: app_store_updated_at..).order(:created_at).last
  end
end
