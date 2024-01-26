class AddCaseDetailsToPriorAuthorityApplications < ActiveRecord::Migration[7.1]
  def change
    change_table :prior_authority_applications, bulk: true do |t|
      t.string :main_offence
      t.date :rep_order_date
      t.string :client_maat_number
      t.boolean :client_detained
      t.string :client_detained_prison
      t.boolean :subject_to_poca
    end
  end
end
