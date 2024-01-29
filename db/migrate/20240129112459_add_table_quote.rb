class AddTableQuote < ActiveRecord::Migration[7.1]
  def change
    create_table :quotes, id: :uuid do |t|
      t.string :service_name
      t.string :contact_full_name
      t.string :organisation
      t.string :postcode
      t.boolean :primary, default: false

      t.timestamps
    end

    add_reference :quotes, :prior_authority_application, foreign_key: true, type: :uuid, null: false
    remove_column :prior_authority_applications, :primary_service, :string
  end
end
