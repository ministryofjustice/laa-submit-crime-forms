class RemoveClientMaatNumberFromPriorAuthorityApplications < ActiveRecord::Migration[7.1]
  def change
    change_table :prior_authority_applications, bulk: true do |t|
      t.remove :client_maat_number
    end
  end
end
