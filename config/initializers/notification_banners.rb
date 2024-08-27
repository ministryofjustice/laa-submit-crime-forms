require Rails.root.join('lib/notification_banner')
require Rails.root.join('lib/host_env')

NotificationBanner.instance.load_config
