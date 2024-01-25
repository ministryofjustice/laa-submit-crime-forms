class AddDefendantToPriorAuthorityApplication < ActiveRecord::Migration[7.1]
  def up
    change_table :defendants, bulk: true do |t|
      t.uuid :defendable_id
      t.string :defendable_type
      t.change :claim_id, :uuid, null: true
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
    end

    Defendant.find_each do |d|
      parts = d.full_name.split(' ', 2)
      d.update(first_name: parts[0], last_name: parts[1], defendable_type: 'Claim', defendable_id: d.claim_id)
    end

    change_table :defendants, bulk: true do |t|
      t.remove :full_name
      t.remove :claim_id
      t.change :defendable_id, :uuid, null: false
      t.change :defendable_type, :string, null: false
    end
  end
end
