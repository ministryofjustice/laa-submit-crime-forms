class RenameYouthCourtClaimedColumnInClaims < ActiveRecord::Migration[8.0]
  def change
    rename_column :claims, :youth_court_fee_claimed, :include_youth_court_fee
  end
end
