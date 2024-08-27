class NotificationBanner
  include Singleton
  attr_reader :message

  def load_config
    config = YAML.load(
      Rails.root.join('config/notification_banner.yml').read
    ).fetch('notification', {})

    @message = config[HostEnv.env_name].present? && within_date_range(config) ? config['message'] : nil
  end

  private

  def within_date_range(config)
    date_from = DateTime.parse(config['date_from'])
    date_to = DateTime.parse(config['date_to'])
    current_date = DateTime.now

    date_from <= current_date && current_date <= date_to
  end
end
