class RemoveLaaReference < ActiveRecord::Migration[8.0]
  def change
    remove_column :claims, :core_search_fields, :virtual
    remove_column :prior_authority_applications, :core_search_fields, :virtual
    remove_column :claims, :laa_reference, :string, force: :cascade
    remove_column :prior_authority_applications, :laa_reference, :string, force: :cascade
  end
end
