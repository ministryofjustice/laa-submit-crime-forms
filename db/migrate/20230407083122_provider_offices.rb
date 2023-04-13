class ProviderOffices < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_offices do |t|
      t.string :guid
      t.string :acccount_no
      t.string :firm_name
      t.string :address_line1
      t.string :address_line2
      t.string :town
      t.string :postcode
      t.timestamps
    end
  end
end
