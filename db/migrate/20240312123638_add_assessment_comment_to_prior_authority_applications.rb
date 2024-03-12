class AddAssessmentCommentToPriorAuthorityApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :prior_authority_applications, :assessment_comment, :string
    change_table :quotes, bulk: true do |t|
      t.string "base_adjustment_comment"
      t.string "travel_adjustment_comment"
    end

    add_column :additional_costs, :adjustment_comment, :string
  end
end
