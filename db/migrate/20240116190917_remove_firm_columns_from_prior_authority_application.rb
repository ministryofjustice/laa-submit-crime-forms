class RemoveFirmColumnsFromPriorAuthorityApplication < ActiveRecord::Migration[7.1]
  def change
    remove_column :prior_authority_applications, :firm_name, :string
    remove_column :prior_authority_applications, :firm_account_number, :string
  end
end
