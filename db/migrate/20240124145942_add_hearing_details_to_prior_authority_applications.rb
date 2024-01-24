class AddHearingDetailsToPriorAuthorityApplications < ActiveRecord::Migration[7.1]
  def change
    change_table :prior_authority_applications, bulk: true do |t|
      t.date :next_hearing_date
      t.string :plea
      t.string :court_type
      t.boolean :youth_court
      t.boolean :psychiatric_liaison
      t.string :psychiatric_liaison_reason_not
    end
  end
end
