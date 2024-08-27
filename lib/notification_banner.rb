class NotificationBanner
  def self.active_banner
    current_date = DateTime.now
    banner_config && date_from <= current_date && date_to >= current_date ? banner_config[:message] : nil
  end

  def self.banner_config
    Rails.configuration.x.notification_banner.notification || nil
  end

  def self.date_from
    DateTime.parse(banner_config[:date_from]) || nil
  end

  def self.date_to
    DateTime.parse(banner_config[:date_to]) || nil
  end
end
