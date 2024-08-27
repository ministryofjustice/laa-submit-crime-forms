class NotificationBanners
  include Singleton
  attr_reader :banners

  def load_config
    config = YAML.load(
      Rails.root.join('config/notifications.yml').read
    ).fetch('notifications', {})

    @banners = config.filter { |banner| banner[HostEnv.env_name].present? }
  end
end
