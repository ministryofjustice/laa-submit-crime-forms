class AddEqualityAnswer < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :answer_equality, :string
  end
end
