class CreateAdditionalCosts < ActiveRecord::Migration[7.1]
  def change
    create_table :additional_costs, id: :uuid do |t|
      t.string :name
      t.text :description
      t.string :unit_type
      t.decimal :cost_per_hour, precision: 10, scale: 2
      t.decimal :cost_per_item, precision: 10, scale: 2
      t.integer :items
      t.integer :period
      t.references :prior_authority_application, foreign_key: true, type: :uuid, null: false

      t.timestamps
    end

    add_column :prior_authority_applications, :additional_costs_still_to_add, :boolean
  end
end
