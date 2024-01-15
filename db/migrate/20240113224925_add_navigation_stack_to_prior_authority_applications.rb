class AddNavigationStackToPriorAuthorityApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :prior_authority_applications, :navigation_stack, :jsonb, array: true, default: []
  end
end
