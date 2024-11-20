class AddColumnYouthCourtFeeClaimedToClaims < ActiveRecord::Migration[8.0]
  def change
    add_column :claims, :youth_court_fee_claimed, :string
  end
end
