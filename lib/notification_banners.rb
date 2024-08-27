class NotificationBanners
  include Singleton
  attr_reader :banners

  def load_config
    config = YAML.load(
      Rails.root.join('config/notifications.yml').read
    ).fetch('notifications', {})

    @banners = config.filter { |banner| banner[HostEnv.env_name].present? && within_date_range(banner) }
  end

  private

  def within_date_range(banner)
    date_from = DateTime.parse(banner['date_from'])
    date_to = DateTime.parse(banner['date_to'])
    current_date = DateTime.now

    date_from <= current_date && current_date <= date_to
  end
end
