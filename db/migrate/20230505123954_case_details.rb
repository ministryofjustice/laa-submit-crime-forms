class CaseDetails < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :main_offence, :text
    add_column :claims, :main_offence_date, :date
    add_column :claims, :assigned_counsel, :string
    add_column :claims, :unassigned_counsel, :string
    add_column :claims, :agent_instructed, :string
    add_column :claims, :remitted_to_magistrate, :string
  end
end
