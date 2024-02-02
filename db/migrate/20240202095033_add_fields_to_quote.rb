class AddFieldsToQuote < ActiveRecord::Migration[7.1]
  def change
    change_table :quotes, bulk: true do |t|
      t.boolean :ordered_by_court
      t.boolean :related_to_post_mortem
      t.string :user_chosen_cost_type
      t.decimal :cost_per_hour, precision: 10, scale: 2
      t.decimal :cost_per_item, precision: 10, scale: 2
      t.integer :items
      t.integer :period
    end

    add_column :prior_authority_applications, :prior_authority_granted, :boolean
  end
end
