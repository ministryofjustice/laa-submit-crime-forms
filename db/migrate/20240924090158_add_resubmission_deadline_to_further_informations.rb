class AddResubmissionDeadlineToFurtherInformations < ActiveRecord::Migration[7.2]
  def change
    add_column :further_informations, :resubmission_deadline, :datetime
  end
end
