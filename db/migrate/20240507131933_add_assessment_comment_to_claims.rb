class AddAssessmentCommentToClaims < ActiveRecord::Migration[7.1]
  def change
    add_column :claims, :assessment_comment, :string
  end
end
