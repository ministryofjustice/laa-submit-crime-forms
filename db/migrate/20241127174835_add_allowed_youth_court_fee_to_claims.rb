class AddAllowedYouthCourtFeeToClaims < ActiveRecord::Migration[8.0]
  def change
    add_column :claims, :allowed_youth_court_fee, :boolean
  end
end
