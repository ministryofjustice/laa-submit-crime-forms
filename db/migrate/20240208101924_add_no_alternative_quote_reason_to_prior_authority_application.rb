class AddNoAlternativeQuoteReasonToPriorAuthorityApplication < ActiveRecord::Migration[7.1]
  def change
    add_column :prior_authority_applications, :no_alternative_quote_reason, :text
    add_column :prior_authority_applications, :alternative_quotes_still_to_add, :boolean
  end
end
