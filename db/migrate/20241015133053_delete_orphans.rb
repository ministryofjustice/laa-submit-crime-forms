class DeleteOrphans < ActiveRecord::Migration[7.2]
  def change
    Solicitor.joins("LEFT JOIN prior_authority_applications pa ON pa.solicitor_id = solicitors.id")
             .joins("LEFT JOIN claims c ON c.solicitor_id = solicitors.id")
             .where("pa.id IS NULL AND c.id IS NULL")
             .destroy_all
    FirmOffice.joins("LEFT JOIN prior_authority_applications pa ON pa.firm_office_id = firm_offices.id")
              .joins("LEFT JOIN claims c ON c.firm_office_id = firm_offices.id")
              .where("pa.id IS NULL AND c.id IS NULL")
              .destroy_all
  end
end
