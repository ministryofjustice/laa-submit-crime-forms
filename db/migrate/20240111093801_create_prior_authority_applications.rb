class CreatePriorAuthorityApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :prior_authority_applications, id: :uuid do |t|
      t.boolean :prison_law
      t.string :ufn
      t.string :contact_name
      t.string :contact_email
      t.string :firm_name
      t.string :firm_account_number
      t.string :laa_reference
      t.string :ufn_form_status, default: 'not_started'
      t.string :case_contact_form_status, default: 'not_started'
      t.string :status, default: 'pre_draft'
      t.references :provider, type: :uuid
      t.timestamps
    end
  end
end
