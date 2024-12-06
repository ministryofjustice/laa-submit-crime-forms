module AppStore
  module V1
    class FurtherInformation < AppStore::V1::Base
      many :supporting_documents, AppStore::V1::SupportingDocument, key: :documents

      attribute :information_requested, :string
      attribute :information_supplied, :string
      attribute :requested_at, :datetime

      delegate :resubmission_deadline, to: :parent
    end
  end
end
