class AddOfficeCodeToPriorAuthorityApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :prior_authority_applications, :office_code, :string, null: false
  end
end
