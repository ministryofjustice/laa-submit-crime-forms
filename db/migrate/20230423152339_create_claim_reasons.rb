class CreateClaimReasons < ActiveRecord::Migration[7.0]
  def change
    create_table :claim_reasons, id: :uuid do |t|

      t.timestamps
    end
  end
end
