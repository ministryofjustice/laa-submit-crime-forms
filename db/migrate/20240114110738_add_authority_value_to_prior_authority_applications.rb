class AddAuthorityValueToPriorAuthorityApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :prior_authority_applications, :authority_value, :boolean
  end
end
