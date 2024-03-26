class DropConfirmationsFromPriorAuthorityApplication < ActiveRecord::Migration[7.1]
  def change
    remove_columns :prior_authority_applications, :confirm_excluding_vat, :confirm_travel_expenditure
  end
end
