class FixBadData < ActiveRecord::Migration[7.0]
  def change
    WorkItem.where(id: Nsm::StartPage::NEW_RECORD).each do |wi|
      wi.id = SecureRandom.uuid
      wi.save
    end
  end
end
