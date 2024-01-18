class RemoveContactDetailColumnsFromPriorAuthorityApplications < ActiveRecord::Migration[7.1]
  def change
    remove_column :prior_authority_applications, :contact_name, :string
    remove_column :prior_authority_applications, :contact_email, :string
  end
end
