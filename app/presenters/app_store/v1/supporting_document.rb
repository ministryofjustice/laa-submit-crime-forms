module AppStore
  module V1
    class SupportingDocument < AppStore::V1::Base
      attribute :file_name, :string
      attribute :file_type, :string
      attribute :file_size, :integer
      attribute :file_path, :string
      attribute :document_type, :string

      def to_param
        # Unfortunately the app store doesn't know the local DB ids of supporting
        # documents, but our download system depends on them, so we have to
        # refer to the local DB.

        # ("file_path" is actually a UUID so this isn't as bad as it looks)
        ::SupportingDocument.find_by(file_path:).try(:id) || 'does-not-exist-locally'
      end
    end
  end
end
