class CreateIncorrectInformations < ActiveRecord::Migration[7.1]
  def change
    create_table :incorrect_informations, id: :uuid do |t|
      t.string :information_requested
      t.jsonb :sections_changed
      t.string :caseworker_id
      t.datetime :requested_at
      t.references :prior_authority_application, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    caseworker_ids = FurtherInformation.pluck(:caseworker_id)
    PriorAuthorityApplication.where.not(incorrect_information_explanation: nil).each do |paa|
      paa.incorrect_informations.create(
        caseworker_id: caseworker_ids.sample,
        information_requested: paa.incorrect_information_explanation,
        requested_at: paa.app_store_updated_at - 60 # to ensure time is before any further info requests
      )
    end
  end
end
