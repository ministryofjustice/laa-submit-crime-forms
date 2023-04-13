class ProviderSolicitors < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_solicitors do |t|
      t.string :guid
      t.string :provider
      t.string :number
      t.string :email
      t.string :reference_number
      t.string :first_name
      t.string :last_name
      t.string :contact_name
      t.string :contact_tel
      t.timestamps
    end
  end
end
