class AddColumnClaimsReasonToClaim < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :claim_reason, :string
  end
end
