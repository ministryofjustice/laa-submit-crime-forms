class AddTownToQuotes < ActiveRecord::Migration[7.1]
  def change
    add_column :quotes, :town, :string
  end
end
