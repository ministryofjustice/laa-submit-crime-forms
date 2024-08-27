class NotificationBanners
  include Singleton
  attr_reader :config

  def load_config
    @config = YAML.load(
      Rails.root.join('config/notifications.yml').read
    ).fetch('notifications', {})
  end
end
