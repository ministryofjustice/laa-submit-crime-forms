class FixWarrantSpelling < ActiveRecord::Migration[7.0]
  def change
    rename_column :claims, :arrest_warrent_date, :arrest_warrant_date
  end
end
