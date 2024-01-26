class AddNextHearingToPriorAuthorityApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :prior_authority_applications, :next_hearing, :boolean
  end
end
