class Quote < ApplicationRecord
  belongs_to :prior_authority_application
  has_one :document, lambda {
                       where(document_type: SupportingDocument::FURTHER_INFORMATION_DOCUMENT)
                     },
          dependent: :destroy,
          inverse_of: :documentable,
          class_name: 'SupportingDocument',
          as: :documentable
end
