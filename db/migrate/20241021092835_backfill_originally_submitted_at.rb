require 'csv'

class BackfillOriginallySubmittedAt < ActiveRecord::Migration[7.2]
  def change
    CSV.parse(File.open(Rails.root.join('db/migrate/20241021_nsm_originally_submitted.csv'))).each do |id, timestamp|
      execute("UPDATE claims SET originally_submitted_at = '#{timestamp}' WHERE id = '#{id}'")
    end

    CSV.parse(File.open(Rails.root.join('db/migrate/20241021_pa_originally_submitted.csv'))).each do |id, timestamp|
      execute("UPDATE prior_authority_applications SET originally_submitted_at = '#{timestamp}' WHERE id = '#{id}'")
    end
  end
end
