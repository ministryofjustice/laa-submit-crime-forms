class CreateIncorrectInformations < ActiveRecord::Migration[7.1]
  def change
    create_table :incorrect_informations, id: :uuid do |t|
      t.string :information_requested
      t.jsonb :sections_changed
      t.string :caseworker_id
      t.datetime :requested_at
      t.references :prior_authority_application, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
