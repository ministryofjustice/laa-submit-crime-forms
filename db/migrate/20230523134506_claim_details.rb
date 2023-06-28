class ClaimDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :prosecution_evidence, :string
    add_column :claims, :defence_statement, :string
    add_column :claims, :number_of_witnesses, :integer
    add_column :claims, :supplemental_claim, :string
    add_column :claims, :preparation_time, :string
    add_column :claims, :time_spent_hours, :integer
    add_column :claims, :time_spent_mins, :integer
    add_column :claims, :work_before_date, :date
    add_column :claims, :work_after_date, :date
  end
end
