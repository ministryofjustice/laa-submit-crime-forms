class RenameBaseAdjustmentCommentToServiceAdjustmentComment < ActiveRecord::Migration[7.1]
  def change
    rename_column :quotes, :base_adjustment_comment, :service_adjustment_comment

    # If there is any test data with an invalid status that could never be returned by the caseworker app,
    # fix it
    PriorAuthorityApplication.where(status: 'part_granted').update_all(status: 'part_grant')
  end
end
