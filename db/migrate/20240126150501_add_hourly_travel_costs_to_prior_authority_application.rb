class AddHourlyTravelCostsToPriorAuthorityApplication < ActiveRecord::Migration[7.1]
  def change
    change_table :prior_authority_applications, bulk: true do |t|
      t.integer :travel_time
      t.decimal :travel_cost_per_hour, precision: 10, scale: 2
      t.text :travel_cost_reason
    end
  end
end
