class ChangeClaimDetailsStringsToIntegers < ActiveRecord::Migration[7.0]
  def change
    change_column :claims, :defence_statement, 'numeric USING CAST(defence_statement AS numeric)'
    change_column :claims, :prosecution_evidence, 'numeric USING CAST(prosecution_evidence AS numeric)'
  end
end
