class SupportingDocument < ApplicationRecord
  SUPPORTING_DOCUMENT = 'supporting_document'.freeze
  PRIMARY_QUOTE_DOCUMENT = 'primary_quote_document'.freeze

  belongs_to :documentable, polymorphic: true

  has_one_attached :file

  scope :supporting_documents, -> { where(document_type: SUPPORTING_DOCUMENT) }
  scope :primary_quote_document, -> { where(document_type: PRIMARY_QUOTE_DOCUMENT) }
end
