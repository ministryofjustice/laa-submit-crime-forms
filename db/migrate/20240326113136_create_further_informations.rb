class CreateFurtherInformations < ActiveRecord::Migration[7.1]
  def change
    create_table :further_informations, id: :uuid do |t|
      t.text :information_requested
      t.text :information_supplied
      t.references :prior_authority_application, type: :uuid
      t.timestamps
    end
  end
end
