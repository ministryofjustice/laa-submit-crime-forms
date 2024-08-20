class BackfillWorkItemPosition < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    # We need to update "post-submitted" claims (only) with one or more nil/null work item positions.
    #
    # These claims should have all their work item position attributes updated to be a 1-based
    # index value when sorted by completed_on and work_type. This sorting algorithm should match
    # what is used for newly submitted claims BUT should not "touch" the work item's updated_at column.
    #

    null_position_work_item_exists = <<~SQL
      EXISTS (SELECT 1 
              FROM work_items w 
              WHERE w.claim_id = claims.id
              AND w.position IS NULL)
    SQL

    Claim.unscoped.where.not(status: [:pre_draft, :draft]).where(null_position_work_item_exists).each do |claim|
      claim.work_items.each do |workitem|
        workitem.update_columns(position: claim.work_item_position(workitem))
      end
    end
  end
end
