class ChangePriorAuthorityApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :prior_authority_applications, :client_first_name, :string
    add_column :prior_authority_applications, :client_last_name, :string
    add_column :prior_authority_applications, :client_date_of_birth, :date
  end
end
