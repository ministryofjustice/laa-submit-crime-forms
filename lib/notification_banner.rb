class NotificationBanner
  def self.active_banner
    return unless banner_config && date_from && date_to

    current_date = DateTime.now
    date_from <= current_date && date_to >= current_date ? banner_config[:message] : nil
  end

  def self.banner_config
    Rails.configuration.x.notification_banner&.notification
  end

  def self.date_from
    DateTime.parse(banner_config[:date_from])
  end

  def self.date_to
    DateTime.parse(banner_config[:date_to])
  end
end
