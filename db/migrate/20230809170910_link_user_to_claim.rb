class LinkUserToClaim < ActiveRecord::Migration[7.0]
  def change
    add_column :claims, :submitter_id, :uuid, index: true
    execute('UPDATE claims SET submitter_id = (SELECT id FROM providers WHERE claims.office_code=ANY(office_codes) limit 1)')
    add_foreign_key :claims, "providers", column: :submitter_id
  end
end
