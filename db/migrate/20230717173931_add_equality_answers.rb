class AddEqualityAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :gender, :string
    add_column :claims, :ethnic_group, :string
    add_column :claims, :disability, :string
  end
end
