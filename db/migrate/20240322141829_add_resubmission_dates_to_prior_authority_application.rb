class AddResubmissionDatesToPriorAuthorityApplication < ActiveRecord::Migration[7.1]
  def change
    add_column :prior_authority_applications, :resubmission_requested, :datetime
    add_column :prior_authority_applications, :resubmission_deadline, :datetime
  end
end
