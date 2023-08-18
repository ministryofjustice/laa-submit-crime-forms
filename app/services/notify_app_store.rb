class NotifyAppStore
  attr_reader :notifier, :message_builder

  def initialize(claim:, scorer: NotifyAppStore::Scorer)
    @message_builder = MessageBuilder.new(claim:, scorer:)
    @notifier = notifier
  end

  def process
    raise 'Sidekiq workers is not yet enabled' if ENV.key?('REDIS_URL')

    # implement and call Sidekiq job

    begin
      notify
    rescue StandardError => e
      # we only get errors here when processing inline, which we don't want
      # to be visible to the end user, so swallow errors
      Sentry.capture_exception(e)
    end
  end

  def notify
    raise 'SNS notification is not yet enabled' if ENV.key?('SNS_URL')

    # implement and call SNS notification

    # TODO: we only do post requests here as the system is not currently
    # able to support re-sending/submitting an appplication so we can ignore
    # put requests
    post_manager = HttpNotifier.new
    post_manager.post(message)
  end

  private

  def message
    message_builder.message
  end
end
