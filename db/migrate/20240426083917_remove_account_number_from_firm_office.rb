class RemoveAccountNumberFromFirmOffice < ActiveRecord::Migration[7.1]
  def change
    remove_column :firm_offices, :account_number, :string
    change_column :prior_authority_applications, :office_code, :string, null: true
  end
end
