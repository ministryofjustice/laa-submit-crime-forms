class PullUpdates < ApplicationJob
  # queue :default

  def perform
    json_data = HttpPuller.new.get_all(last_update)

    json_data['applications'].each do |record|
      case record['application_type']
      when 'crm7'
        update_claim(record['application_id'], convert_params(record))
      when 'crm4'
        update_prior_authority_application(record['application_id'], convert_params(record))
      end
    end
  end

  private

  def last_update
    [
      Claim.where.not(app_store_updated_at: nil).maximum(:app_store_updated_at),
      PriorAuthorityApplication.where.not(app_store_updated_at: nil).maximum(:app_store_updated_at),
      Time.zone.local(2023, 1, 1)
    ].compact.max
  end

  def convert_params(record)
    {
      status: record['application_state'],
      app_store_updated_at: record['updated_at'],
    }
  end

  def update_claim(claim_id, params)
    claim = Claim.find_by(id: claim_id)

    claim&.update!(params)
  end

  def update_prior_authority_application(application_id, params)
    application = PriorAuthorityApplication.find_by(id: application_id)

    application&.update!(params)
  end
end
