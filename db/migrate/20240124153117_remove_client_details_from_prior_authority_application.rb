class RemoveClientDetailsFromPriorAuthorityApplication < ActiveRecord::Migration[7.1]
  def change
    change_table :prior_authority_applications, bulk: true do |t|
      t.remove :client_date_of_birth
      t.remove :client_first_name
      t.remove :client_last_name
    end
  end
end
