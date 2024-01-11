class CreatePriorAuthorityApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :prior_authority_applications, id: :uuid do |t|
      t.references :provider, type: :uuid
      t.references :firm_office, foreign_key: true, type: :uuid, null: true
      t.references :solicitor, foreign_key: true, type: :uuid, null: true

      t.string :office_code, null: false
      t.boolean :prison_law
      t.boolean :authority_value
      t.string :ufn
      t.string :laa_reference
      t.string :status, default: 'pre_draft'
      t.string :client_first_name
      t.string :client_last_name
      t.date :client_date_of_birth
      t.jsonb :navigation_stack, array: true, default: []

      t.timestamps
    end
  end
end
