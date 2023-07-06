class ChangeClaimDetailsStringsToIntegers < ActiveRecord::Migration[7.0]
  def change
    change_column :claims, :defence_statement, 'integer USING CAST(defence_statement AS integer)'
    change_column :claims, :prosecution_evidence, 'integer USING CAST(prosecution_evidence AS integer)'
  end
end
