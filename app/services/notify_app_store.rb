class NotifyAppStore
  attr_reader :notifier, :message_builder

  def initialize(claim:, scorer:)
    @message_builder = MessageBuilder.new(claim:, scorer:)
    @notifier = notifier
  end

  def notify
    if ENV.key?('SNS_URL')
      # implement and call SNS notification
      raise 'SNS notification is not yet enabled'
    else
      post_manager = HttpNotifier.new
      post_manager.post(message)
    end
  end

  private

  def message
    message_builder.message
  end
end
