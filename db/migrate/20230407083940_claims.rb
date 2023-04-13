class Claims < ActiveRecord::Migration[7.0]
  def change
    create_table :claims do |t|
      t.string :guid
      t.string :usn
      t.string :account_no
      t.string :provider_no
      t.boolean :assigned_counsel
      t.string :rep_order
      t.string :cntp_number
      t.datetime :rep_date
      t.datetime :cntp_date
      t.timestamps
    end
  end
end
