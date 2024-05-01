class MakeOfficeCodeNullable < ActiveRecord::Migration[7.1]
  def change
    change_column :claims, :office_code, :string, null: true
  end
end
