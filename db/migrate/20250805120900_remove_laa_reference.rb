class RemoveLaaReference < ActiveRecord::Migration[8.0]
  def change
    remove_column :claims, :laa_reference, :string
    remove_column :prior_authority_applications, :laa_reference, :string
  end
end
