class SupportingDocument < ApplicationRecord
  before_update :remove_old_file

  SUPPORTING_DOCUMENT = 'supporting_document'.freeze
  SUPPORTED_FILE_TYPES = 'quote_document'.freeze

  belongs_to :documentable, polymorphic: true

  scope :supporting_documents, -> { where(document_type: SUPPORTING_DOCUMENT) }

  private

  def parent
    @parent ||= case documentable_type
                when 'Quote'
                  documentable.prior_authority_application
                when 'FurtherInformation'
                  documentable.submission
                else
                  documentable
                end
  end

  def remove_old_file
    return unless file_path_changed? && parent.sent_back?

    DeleteAttachment.set(wait: 24.hours).perform_later(file_path_was)
  end
end
