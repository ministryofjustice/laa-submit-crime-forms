class SupportingEvidence < ApplicationRecord
  self.table_name = 'supporting_evidence'
  belongs_to :claim

  attribute :file_name
  attribute :file_type
  attribute :file_size
  attribute :case_id
  attribute :id
  attribute :send_by_post

  has_one_attached :file
end