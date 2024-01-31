class SupportingDocument < ApplicationRecord
  SUPPORTING_DOCUMENT = 'supporting_document'.freeze
  belongs_to :documentable, polymorphic: true

  has_one_attached :file

  scope :supporting_documents, -> { where(document_type: SUPPORTING_DOCUMENT) }
end
