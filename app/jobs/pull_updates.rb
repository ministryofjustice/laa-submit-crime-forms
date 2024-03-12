class PullUpdates < ApplicationJob
  EARLIEST_POLL_DATE = Time.zone.local(2023, 1, 1)
  # queue :default

  def perform(count: 100)
    since = last_update

    loop do
      json_data = AppStoreClient.new.get_all(since:, count:)
      break if json_data['applications'].none?

      last_updated = process(json_data['applications'])
      break if since == last_updated

      since = last_updated
    end
  end

  def process(applications)
    applications.each do |record|
      case record['application_type']
      when 'crm7'
        update_claim(record['application_id'], convert_params(record))
      when 'crm4'
        update_prior_authority_application(record['application_id'], convert_params(record))
      end
    end

    last_updated_str = applications.pluck('updated_at').max

    Time.zone.parse(last_updated_str)
  end

  private

  def last_update
    [
      Claim.where.not(app_store_updated_at: nil).maximum(:app_store_updated_at),
      PriorAuthorityApplication.where.not(app_store_updated_at: nil).maximum(:app_store_updated_at),
      EARLIEST_POLL_DATE
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
    PriorAuthority::CostSyncer.call(application)
  end
end
