module AppStore
  module V1
    module Nsm
      class WorkItem < AppStore::V1::Base
        alias claim parent
        alias application parent

        include WorkItemDetails

        attribute :id, :string
        adjustable_attribute :work_type, :possibly_translated_string
        adjustable_attribute :time_spent, :integer
        attribute :completed_on, :date
        attribute :fee_earner, :string
        adjustable_attribute :uplift, :integer
        attribute :created_at, :datetime
        attribute :updated_at, :datetime
        attribute :adjustment_comment, :string
        attribute :position, :integer

        def claim_id
          parent.id
        end
      end
    end
  end
end
