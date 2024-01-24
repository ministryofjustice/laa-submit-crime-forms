class RemoveClientDetailsFromPriorAuthorityApplication < ActiveRecord::Migration[7.1]
  def change
    PriorAuthorityApplication.find_each do |application|
      Defendant.create!(
        defendable_id: application.id,
        defendable_type: 'PriorAuthorityApplication',
        first_name: application.client_first_name,
        last_name: application.client_last_name,
        date_of_birth: application.client_date_of_birth,
      )
    end

    change_table :prior_authority_applications, bulk: true do |t|
      t.remove :client_date_of_birth
      t.remove :client_first_name
      t.remove :client_last_name
    end
  end
end
