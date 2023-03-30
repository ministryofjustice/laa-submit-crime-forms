class CreateClaims < ActiveRecord::Migration[7.0]
  def change
    create_table :claims do |t|
      t.string :full_name
      t.string :reference
      t.string :tel_number
      t.string :email
      t.string :address_line1
      t.string :town
      t.string :post_code

      t.timestamps
    end
  end
end
