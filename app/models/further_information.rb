class FurtherInformation < ApplicationRecord
  belongs_to :prior_authority_application
  has_many :supporting_documents, -> { order(:created_at, :file_name).supporting_documents },
           dependent: :destroy,
           inverse_of: :documentable,
           class_name: 'SupportingDocument',
           as: :documentable
end
