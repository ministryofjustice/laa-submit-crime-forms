class BackfillDisbursementPosition < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    # We need to update "post-submitted" claims (only) with one or more nil/null disbursement positions.
    #
    # These claims should have all their disbursements position attributes updated to be a 1-based
    # index value when sorted by disbursement_date and "translated disbursement type description". This
    # sorting algorithm should match what is used for newly submitted claims BUT should not "touch" the
    # disbursements updated_at column.
    #

    null_position_disbursement_exists = <<~SQL
      EXISTS (SELECT 1 
              FROM disbursements d 
              WHERE d.claim_id = claims.id
              AND d.position IS NULL)
    SQL

    Claim.unscoped.where.not(status: [:pre_draft, :draft]).where(null_position_disbursement_exists).each do |claim|
      claim.disbursements.each do |disbursement|
        disbursement.update_columns(position: claim.disbursement_position(disbursement))
      end
    end
  end
end
