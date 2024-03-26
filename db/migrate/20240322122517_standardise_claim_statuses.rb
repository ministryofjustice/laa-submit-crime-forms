class StandardiseClaimStatuses < ActiveRecord::Migration[7.1]
  def up
    execute("UPDATE claims SET status = 'submitted' WHERE status = 'completed'")
    execute("UPDATE claims SET status = 'part_grant' WHERE status = 'part-granted'")
  end

  def down
    execute("UPDATE claims SET status = 'completed' WHERE status = 'submitted'")
    execute("UPDATE claims SET status = 'part-granted' WHERE status = 'part_grant'")
  end
end
