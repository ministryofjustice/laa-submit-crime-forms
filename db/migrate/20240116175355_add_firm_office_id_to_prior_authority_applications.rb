class AddFirmOfficeIdToPriorAuthorityApplications < ActiveRecord::Migration[7.1]
  def change
    add_reference :prior_authority_applications, :firm_office, foreign_key: true, type: :uuid, null: true
  end
end
