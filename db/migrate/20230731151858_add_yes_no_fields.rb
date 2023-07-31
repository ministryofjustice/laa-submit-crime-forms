class AddYesNoFields < ActiveRecord::Migration[7.0]
  def change
    # claim details
    add_column :claims, :preparation_time, :string
    add_column :claims, :work_before, :string
    add_column :claims, :work_after, :string

    # add disbursement
    add_column :claims, :has_disbursements, :string

    Claim.where(time_spent: nil).update_all(preparation_time: 'no')
    Claim.where.not(time_spent: nil).update_all(preparation_time: 'yes')

    Claim.where(work_before_date: nil).update_all(work_before: 'no')
    Claim.where.not(work_before_date: nil).update_all(work_before: 'yes')

    Claim.where(work_after_date: nil).update_all(work_after: 'no')
    Claim.where.not(work_after_date: nil).update_all(work_after: 'yes')

    Claim.joins(:disbursements).update_all(has_disbursements: 'yes')
    Claim.left_joins(:disbursements).where(disbursements: { id: nil }).update_all(has_disbursements: 'no')
  end
end
