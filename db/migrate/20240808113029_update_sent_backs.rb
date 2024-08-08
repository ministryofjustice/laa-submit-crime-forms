class UpdateSentBacks < ActiveRecord::Migration[7.1]
  def change
    Claim.where(status: 'further_info').update_all(status: 'sent_back')
  end
end
