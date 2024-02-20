class AddConfirmationsToPriorAuthorityApplications < ActiveRecord::Migration[7.1]
  def change
    change_table :prior_authority_applications, bulk: true do |t|
      t.boolean :confirm_excluding_vat
      t.boolean :confirm_travel_expenditure
    end
  end
end
