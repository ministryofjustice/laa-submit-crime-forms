class AddPositionToDisbursements < ActiveRecord::Migration[7.1]
  def change
    add_column :disbursements, :position, :integer
  end
end
