class AddMainOffenceIdToPriorAuthorityApplication < ActiveRecord::Migration[7.1]
  def up
    change_table :prior_authority_applications, bulk: true do |t|
      t.string :main_offence_id
      t.string :custom_main_offence_name
      t.string :prison_id
      t.string :custom_prison_name
    end

    PriorAuthorityApplication.find_each do |application|
      application.update!(
        main_offence_id: 'custom',
        custom_main_offence_name: application.main_offence,
        prison_id: 'custom',
        custom_prison_name: application.client_detained_prison
      )
    end

    change_table :prior_authority_applications, bulk: true do |t|
      t.remove :main_offence, type: :string
      t.remove :client_detained_prison, type: :string
    end
  end

  def down
    change_table :prior_authority_applications, bulk: true do |t|
      t.string :main_offence
      t.string :client_detained_prison
    end

    PriorAuthorityApplication.find_each do |application|
      application.update!(
        main_offence: application.custom_main_offence_name,
        client_detained_prison: application.custom_prison_name
      )
    end

    change_table :prior_authority_applications, bulk: true do |t|
      t.remove :main_offence_id, type: :string
      t.remove :custom_main_offence_name, type: :string
      t.remove :prison_id, type: :string
      t.remove :custom_prison_name, type: :string
    end
  end
end
