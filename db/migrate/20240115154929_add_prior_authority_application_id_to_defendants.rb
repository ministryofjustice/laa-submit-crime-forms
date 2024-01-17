class AddPriorAuthorityApplicationIdToDefendants < ActiveRecord::Migration[7.1]
  def change
    add_column :defendants, :prior_authority_application_id, :string
  end
end
