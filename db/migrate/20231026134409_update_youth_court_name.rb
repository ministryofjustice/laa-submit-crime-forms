class UpdateYouthCourtName < ActiveRecord::Migration[7.1]
  def change
    rename_column :claims, :youth_count, :youth_court
  end
end
