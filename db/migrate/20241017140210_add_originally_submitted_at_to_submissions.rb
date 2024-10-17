class AddOriginallySubmittedAtToSubmissions < ActiveRecord::Migration[7.2]
  def change
    add_column :claims, :originally_submitted_at, :datetime
    add_column :prior_authority_applications, :originally_submitted_at, :datetime
  end
end
