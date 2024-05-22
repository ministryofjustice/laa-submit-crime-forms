class AddAdjustmentColumns < ActiveRecord::Migration[7.1]
  def change
    change_table :work_items, bulk: true do |t|
      t.integer "allowed_uplift"
      t.integer "allowed_time_spent"
      t.string "adjustment_comment"
    end

    change_table :disbursements, bulk: true do |t|
      t.decimal "allowed_total_cost_without_vat"
      t.decimal "allowed_vat_amount"
      t.string "adjustment_comment"
    end

    change_table :claims, bulk: true do |t|
      t.integer "allowed_letters"
      t.integer "allowed_calls"
      t.integer "allowed_letters_uplift"
      t.integer "allowed_calls_uplift"
      t.string "letters_adjustment_comment"
      t.string "calls_adjustment_comment"
    end
  end
end
