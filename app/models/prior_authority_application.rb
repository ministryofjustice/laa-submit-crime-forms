class PriorAuthorityApplication < ApplicationRecord
  include PriorAuthorityDetails

  before_destroy :destroy_attachments

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
  has_many :further_informations, dependent: :destroy, inverse_of: :submission, as: :submission
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

  def pending_further_information
    further_informations.where(created_at: app_store_updated_at..).order(:created_at).last
  end

  def pending_incorrect_information
    incorrect_informations.where(created_at: app_store_updated_at..).order(:created_at).last
  end

  def dup
    super.tap do |new_record|
      new_record.defendant = defendant.dup if defendant.present?
      new_record.quotes = quotes.map(&:dup)

      new_record.supporting_documents = supporting_documents.map(&:dup)

      new_record.additional_costs = additional_costs.map(&:dup)
      new_record.further_informations = further_informations.map(&:dup)
      new_record.incorrect_informations = incorrect_informations.map(&:dup)
    end
  end

  private

  def file_uploader
    @file_uploader ||= FileUpload::FileUploader.new
  end

  def destroy_attachments
    return unless state == 'draft'

    destroy_supporting_documents
    destroy_quote_documents
    destroy_further_informations
  end

  def destroy_supporting_documents
    supporting_documents.each do |file|
      file_uploader.destroy(file.file_path) if file_uploader.exists?(file.file_path)
    end
  end

  def destroy_quote_documents
    quotes.each do |quote|
      next if quote.document.nil?

      file_uploader.destroy(quote.document.file_path) if file_uploader.exists?(quote.document.file_path)
    end
  end

  def destroy_further_informations
    further_informations.each do |fi|
      fi.supporting_documents.each do |file|
        file_uploader.destroy(file.file_path) if file_uploader.exists?(file.file_path)
      end
    end
  end
end
