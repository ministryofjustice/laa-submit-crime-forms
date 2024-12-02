class AddYouthCourtFeeAdjustmentCommentToClaims < ActiveRecord::Migration[8.0]
  def change
    add_column :claims, :youth_court_fee_adjustment_comment, :string
  end
end
