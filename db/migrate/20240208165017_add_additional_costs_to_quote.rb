class AddAdditionalCostsToQuote < ActiveRecord::Migration[7.1]
  def change
    add_column :quotes, :additional_cost_list, :text
    add_column :quotes, :additional_cost_total, :decimal, precision: 10, scale: 2
  end
end
