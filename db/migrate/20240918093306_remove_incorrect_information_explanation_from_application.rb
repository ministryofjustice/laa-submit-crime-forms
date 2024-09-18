class RemoveIncorrectInformationExplanationFromApplication < ActiveRecord::Migration[7.2]
  def change
    remove_column :prior_authority_applications, :incorrect_information_explanation, :string
  end
end
