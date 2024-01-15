class AddDefendantAssociations < ActiveRecord::Migration[7.1]
  def change
    create_table :defendants_claims do |t|
      t.string :defendant_id
      t.string :claim_id
    end
    add_index :defendants_claims, :defendant_id, unique: true

    create_table :defendants_prior_authority_applications do |t|
      t.string :defendant_id
      t.string :prior_authority_application_id
    end
    add_index :defendants_prior_authority_applications, :defendant_id, unique: true
  end
end
