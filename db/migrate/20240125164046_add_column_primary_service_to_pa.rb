class AddColumnPrimaryServiceToPa < ActiveRecord::Migration[7.1]
  def change
    add_column :prior_authority_applications, :primary_service, :string
  end
end
