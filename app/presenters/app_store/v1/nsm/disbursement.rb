module AppStore
  module V1
    module Nsm
      class Disbursement < AppStore::V1::Base
        alias claim parent
        alias application parent
        def record
          self
        end

        include DisbursementDetails

        attribute :id, :string
        attribute :disbursement_date, :date
        attribute :disbursement_type, :string
        attribute :other_type, :string
        adjustable_attribute :miles, :decimal
        adjustable_attribute :total_cost_without_vat, :decimal
        attribute :details, :string
        attribute :prior_authority, :string
        adjustable_attribute :apply_vat, :string
        attribute :created_at, :datetime
        attribute :updated_at, :datetime
        adjustable_attribute :vat_amount, :decimal
        attribute :adjustment_comment, :string
        attribute :position, :integer
      end
    end
  end
end
