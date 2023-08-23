class UpdatePlea < ActiveRecord::Migration[7.0]
  def change
    Claim.where(plea: 'discontinuance').update_all(plea: 'discontinuance_cat1')
  end
end
