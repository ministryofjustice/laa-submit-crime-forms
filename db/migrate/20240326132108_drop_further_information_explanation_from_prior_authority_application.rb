class DropFurtherInformationExplanationFromPriorAuthorityApplication < ActiveRecord::Migration[7.1]
  def change
    remove_column :prior_authority_applications, :further_information_explanation
  end
end
