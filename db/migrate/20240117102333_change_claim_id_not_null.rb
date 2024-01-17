class ChangeClaimIdNotNull < ActiveRecord::Migration[7.1]
  def change
    change_column :defendants, :claim_id, :uuid, :null => true
  end
end
