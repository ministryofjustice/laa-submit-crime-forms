class MoveFieldsAround < ActiveRecord::Migration[7.1]
  def change
    change_table :prior_authority_applications, bulk: true do |t|
      t.string :service_type
      t.string :custom_service_name
      t.remove :travel_time, type: :integer
      t.remove :travel_cost_per_hour, type: :decimal, precision: 10, scale: 2
      t.remove :travel_cost_reason, type: :text
    end

    change_table :quotes, bulk: true do |t|
      t.remove :service_type, type: :string
      t.remove :custom_service_name, type: :string
      t.integer :travel_time
      t.decimal :travel_cost_per_hour, precision: 10, scale: 2
      t.text :travel_cost_reason
    end
  end
end
