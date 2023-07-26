class SupportingEvidence < ApplicationRecord
  self.table_name = 'supporting_evidence'
  belongs_to :claim

  has_one_attached :file
end
