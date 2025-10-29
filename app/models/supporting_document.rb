class SupportingDocument < ApplicationRecord
  SUPPORTING_DOCUMENT = 'supporting_document'.freeze
  SUPPORTED_FILE_TYPES = 'quote_document'.freeze

  belongs_to :documentable, touch: true, polymorphic: true

  scope :supporting_documents, -> { where(document_type: SUPPORTING_DOCUMENT) }
end
