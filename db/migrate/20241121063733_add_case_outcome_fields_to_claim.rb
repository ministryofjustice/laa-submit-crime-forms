class AddCaseOutcomeFieldsToClaim < ActiveRecord::Migration[7.2]
  def change
    change_table :claims do |t|
      t.date :change_solicitor_date
      t.string :case_outcome_other_info
    end
  end
end
