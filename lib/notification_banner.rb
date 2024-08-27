class NotificationBanner
  def self.active_banner
    current_date = DateTime.now
    date_from <= current_date && date_to >= current_date ? banner_config[:message] : nil
  end

  def self.banner_config
    Rails.configuration.x.notification_banner&.notification
  end

  def self.date_from
    banner_config ? DateTime.parse(banner_config[:date_from]) : nil
  end

  def self.date_to
    banner_config ? DateTime.parse(banner_config[:date_to]) : nil
  end
end
