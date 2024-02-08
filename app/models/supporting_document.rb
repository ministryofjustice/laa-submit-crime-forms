class SupportingDocument < ApplicationRecord
  SUPPORTING_DOCUMENT = 'supporting_document'.freeze
  QUOTE_DOCUMENT = 'quote_document'.freeze

  belongs_to :documentable, polymorphic: true

  has_one_attached :file

  scope :supporting_documents, -> { where(document_type: SUPPORTING_DOCUMENT) }
  scope :quote_ocument, -> { where(document_type: QUOTE_DOCUMENT) }
end
