class PullUpdates < ApplicationJob
  # queue :default

  def perform
    last_update = Claim.where.not(app_store_updated_at: nil)
                       .maximum(:app_store_updated_at) || Time.zone.local(2023, 1, 1)

    json_data = HttpPuller.new.get_all(last_update)

    json_data['applications'].each do |record|
      save(record['application_id'], convert_params(record))
    end
  end

  private

  def convert_params(record)
    {
      status: record['application_state'],
      app_store_updated_at: record['updated_at'],
    }
  end

  def save(claim_id, params)
    claim = Claim.find_by(id: claim_id)

    claim&.update!(params)
  end
end
