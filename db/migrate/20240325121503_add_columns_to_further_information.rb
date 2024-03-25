class AddColumnsToFurtherInformation < ActiveRecord::Migration[7.1]
  def change
    add_column :further_informations, :caseworker_id, :uuid
    add_column :further_informations, :requested_at, :datetime
    add_column :further_informations, :expired_at, :datetime
    remove_column :prior_authority_applications, :further_information_explanation
    remove_column :prior_authority_applications, :incorrect_information_explanation
  end
end
