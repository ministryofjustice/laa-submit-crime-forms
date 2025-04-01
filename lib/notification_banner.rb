class NotificationBanner
  def self.active_banner
    return unless banner_config && date_from && date_to

    current_date = DateTime.now
    current_date.between?(date_from, date_to) ? banner_config[:message] : nil
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
