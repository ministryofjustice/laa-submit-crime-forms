class FailedImport < ApplicationRecord
  belongs_to :provider
  has_one :error_file,
          dependent: :destroy,
          inverse_of: :documentable,
          class_name: 'SupportingDocument',
          as: :documentable
end
