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
      AppStoreUpdateProcessor.call(record)
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
end
