module AppStore
  module V1
    class FurtherInformation < AppStore::V1::Base
      many :supporting_documents, AppStore::V1::SupportingDocument, key: :documents

      attribute :information_requested, :string
      attribute :information_supplied, :string
      attribute :caseworker_id, :string
      attribute :requested_at, :datetime

      delegate :resubmission_deadline, to: :parent

      def local_record
        @local_record ||= ::FurtherInformation.find_or_create_by(
          submission: parent.local_record,
          caseworker_id: caseworker_id,
          information_requested: information_requested,
          requested_at: requested_at
        )
      end

      delegate :update!, to: :local_record

      def as_json(*)
        return app_store_record if previously_completed?

        attributes.merge(
          'information_supplied' => local_record.information_supplied,
          'signatory_name' => local_record.signatory_name,
          'documents' => documents
        ).as_json
      end

      def documents
        local_record.supporting_documents.map do |document|
          document.as_json(only: %i[file_name
                                    file_type
                                    file_size
                                    file_path
                                    document_type])
        end
      end

      def previously_completed?
        information_supplied.present?
      end
    end
  end
end
