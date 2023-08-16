class ChangePendingToDraft < ActiveRecord::Migration[7.0]
  def change
    change_column :claims, :status, :string, default: 'draft'
    Claim.where(status: 'pending').update_all(status: 'draft')
  end
end
