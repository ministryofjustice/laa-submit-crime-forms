class RenameTransferredFromToTransferredTo < ActiveRecord::Migration[7.2]
  def change
    rename_column :claims,
                  :transferred_from_undesignated_area,
                  :transferred_to_undesignated_area
  end
end
