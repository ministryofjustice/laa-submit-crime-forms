class AddRfiColumnsToPriorAuthorityApplication < ActiveRecord::Migration[7.1]
  def change
    add_column :prior_authority_applications, :further_information_explanation, :string
    add_column :prior_authority_applications, :incorrect_information_explanation, :string
  end
end
