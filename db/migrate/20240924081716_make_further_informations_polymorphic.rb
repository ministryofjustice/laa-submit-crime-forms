class MakeFurtherInformationsPolymorphic < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key :further_informations, :prior_authority_applications
    rename_column :further_informations, :prior_authority_application_id, :submission_id
    add_column :further_informations, :submission_type, :string

    execute("UPDATE further_informations SET submission_type = 'PriorAuthorityApplication'")
  end
end
