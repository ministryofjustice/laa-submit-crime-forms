require Rails.root.join('lib/notification_banners')
require Rails.root.join('lib/host_env')

NotificationBanners.instance.load_config
