class AddServiceTypeIndex < ActiveRecord::Migration[7.2]
  def up
    add_index :prior_authority_applications,
              [:created_at, :service_type],
              name: 'idx_pas_service_type_created_at',
              where: "service_type IS NOT NULL AND service_type != ''"
  end

  def down
    remove_index :prior_authority_applications,
                 name: 'idx_pas_service_type_created_at'
  end
end
