class AddColumnReasonForClaim < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :reasons_for_claim, :jsonb, default: []
    add_column :claims, :representation_order_withdrawn_date  , :date
    add_column :claims, :reason_for_claim_other_details, :text
  end
end
